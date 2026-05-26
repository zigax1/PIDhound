import Foundation
import Darwin.Mach

public struct CPUReading: Sendable, Equatable {
    public let cpuPercent: Double
}

public final class CPUSampler: @unchecked Sendable {
    private var lastTicks: (user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)?

    public init() {}

    public func sample() -> CPUReading {
        guard let current = readTicks() else { return CPUReading(cpuPercent: 0) }
        defer { lastTicks = current }
        guard let prev = lastTicks else { return CPUReading(cpuPercent: 0) }

        let userDelta  = Double(current.user  &- prev.user)
        let sysDelta   = Double(current.system &- prev.system)
        let idleDelta  = Double(current.idle   &- prev.idle)
        let niceDelta  = Double(current.nice   &- prev.nice)

        let active = userDelta + sysDelta + niceDelta
        let total = active + idleDelta
        guard total > 0 else { return CPUReading(cpuPercent: 0) }
        let pct = (active / total) * 100.0
        return CPUReading(cpuPercent: max(0, min(100, pct)))
    }

    private func readTicks() -> (user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)? {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &info) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        return (info.cpu_ticks.0, info.cpu_ticks.1, info.cpu_ticks.2, info.cpu_ticks.3)
    }
}
