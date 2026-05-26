import Foundation
import Darwin

public final class ProcessLister: @unchecked Sendable {
    private var lastCPUTimeNS: [Int32: UInt64] = [:]
    private var lastSampleTime: Date?

    public init() {}

    public func sample(at now: Date = Date()) -> [ProcessSnapshot] {
        let kinfos = listAllProcesses()
        let elapsed = lastSampleTime.map { now.timeIntervalSince($0) } ?? 0
        var newCPUTime: [Int32: UInt64] = [:]
        var results: [ProcessSnapshot] = []

        for kinfo in kinfos {
            let pid = kinfo.kp_proc.p_pid
            guard pid > 0 else { continue }

            // Get task info for CPU/RSS. May fail for some processes — that's OK,
            // we still include them with zero values.
            let task = getTaskInfo(pid: pid)

            let totalCPUTimeNS: UInt64
            let rss: UInt64
            if let task {
                totalCPUTimeNS = task.pti_total_user + task.pti_total_system
                rss = task.pti_resident_size
            } else {
                totalCPUTimeNS = 0
                rss = 0
            }
            newCPUTime[pid] = totalCPUTimeNS

            let cpuPercent: Double
            if let prev = lastCPUTimeNS[pid], elapsed > 0, task != nil {
                let deltaNS = Double(totalCPUTimeNS &- prev)
                let elapsedNS = elapsed * 1_000_000_000
                cpuPercent = max(0, (deltaNS / elapsedNS) * 100)
            } else {
                cpuPercent = 0
            }

            let path = getProcessPath(pid: pid)

            // Extract p_comm (16-byte process name) from the extern_proc struct
            let commName = withUnsafeBytes(of: kinfo.kp_proc.p_comm) { rawBuf -> String in
                let bytes = rawBuf.bindMemory(to: CChar.self)
                return String(cString: bytes.baseAddress!)
            }

            // Get full args via sysctl KERN_PROCARGS2 (best-effort)
            let args = getProcessArgs(pid: pid) ?? []
            // Prefer argv[0] basename if we got it and it's longer/more descriptive than p_comm
            let argv0Name: String = {
                guard let first = args.first else { return "" }
                let base = (first as NSString).lastPathComponent
                return base
            }()
            let displayName = !argv0Name.isEmpty && argv0Name.count > commName.count ? argv0Name : commName

            let cwd = getProcessCWD(pid: pid)
            let ppid = Int32(kinfo.kp_eproc.e_ppid)
            let startSec = TimeInterval(kinfo.kp_proc.p_starttime.tv_sec)
            let startUsec = TimeInterval(kinfo.kp_proc.p_starttime.tv_usec) / 1_000_000
            let startTime = Date(timeIntervalSince1970: startSec + startUsec)

            results.append(ProcessSnapshot(
                pid: pid, ppid: ppid, name: displayName,
                executablePath: path, argv: args, cwd: cwd,
                cpuPercent: cpuPercent, residentSizeBytes: rss,
                startTime: startTime
            ))
        }

        lastCPUTimeNS = newCPUTime
        lastSampleTime = now
        return results
    }

    // MARK: - sysctl enumeration

    private func listAllProcesses() -> [kinfo_proc] {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var size = 0

        // First call: get required buffer size
        guard sysctl(&mib, u_int(mib.count), nil, &size, nil, 0) == 0, size > 0 else {
            return []
        }

        // Allocate a bit extra in case more processes spawn between calls
        let entrySize = MemoryLayout<kinfo_proc>.stride
        let extraEntries = 64
        let allocSize = size + extraEntries * entrySize
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: allocSize, alignment: MemoryLayout<kinfo_proc>.alignment)
        defer { buffer.deallocate() }

        var actualSize = allocSize
        guard sysctl(&mib, u_int(mib.count), buffer, &actualSize, nil, 0) == 0 else {
            return []
        }

        let count = actualSize / entrySize
        let typedPtr = buffer.bindMemory(to: kinfo_proc.self, capacity: count)
        return Array(UnsafeBufferPointer(start: typedPtr, count: count))
    }

    // MARK: - libproc helpers (per-pid detail enrichment)

    private func getTaskInfo(pid: Int32) -> proc_taskinfo? {
        var info = proc_taskinfo()
        let size = Int32(MemoryLayout<proc_taskinfo>.stride)
        let result = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, size)
        return result > 0 ? info : nil
    }

    private func getProcessPath(pid: Int32) -> String {
        var buf = [CChar](repeating: 0, count: 4096)
        let result = proc_pidpath(pid, &buf, UInt32(buf.count))
        guard result > 0 else { return "" }
        return String(cString: buf)
    }

    private func getProcessCWD(pid: Int32) -> String? {
        var info = proc_vnodepathinfo()
        let size = Int32(MemoryLayout<proc_vnodepathinfo>.stride)
        let result = proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &info, size)
        guard result > 0 else { return nil }
        let path = withUnsafeBytes(of: info.pvi_cdir.vip_path) { rawBuf -> String in
            let bytes = rawBuf.bindMemory(to: CChar.self)
            return String(cString: bytes.baseAddress!)
        }
        return path.isEmpty ? nil : path
    }

    private func getProcessArgs(pid: Int32) -> [String]? {
        var size = 0
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 0 else { return nil }

        var buf = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buf, &size, nil, 0) == 0 else { return nil }

        let argc: Int32 = buf.withUnsafeBufferPointer { ptr in
            ptr.baseAddress!.withMemoryRebound(to: Int32.self, capacity: 1) { $0.pointee }
        }
        guard argc >= 0 else { return nil }

        var pos = 4
        while pos < size && buf[pos] != 0 { pos += 1 }
        while pos < size && buf[pos] == 0 { pos += 1 }

        var args: [String] = []
        for _ in 0..<Int(argc) {
            let start = pos
            while pos < size && buf[pos] != 0 { pos += 1 }
            if pos > start {
                let s = String(bytes: buf[start..<pos], encoding: .utf8) ?? ""
                args.append(s)
            }
            pos += 1
            if pos >= size { break }
        }
        return args
    }
}
