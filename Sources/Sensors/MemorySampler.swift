import Foundation
import Darwin.Mach

public struct MemoryReading: Sendable, Equatable {
    public let usedBytes: UInt64
    public let totalBytes: UInt64
}

public struct MemorySampler: Sendable {
    public init() {}

    public func sample() -> MemoryReading {
        let total = ProcessInfo.processInfo.physicalMemory
        let used = currentlyUsedBytes() ?? total / 2
        return MemoryReading(usedBytes: used, totalBytes: total)
    }

    private func currentlyUsedBytes() -> UInt64? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        let pageSize = UInt64(vm_kernel_page_size)
        let active = UInt64(stats.active_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize
        return active + inactive + wired + compressed
    }
}
