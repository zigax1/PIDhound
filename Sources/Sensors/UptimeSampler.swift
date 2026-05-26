import Foundation
import Darwin

public struct UptimeReading: Sendable, Equatable {
    public let uptimeSeconds: TimeInterval
    public let awakeSeconds: TimeInterval
}

public struct UptimeSampler: Sendable {
    public init() {}

    public func sample() -> UptimeReading {
        let uptime = ProcessInfo.processInfo.systemUptime
        let bootDate = bootTime()
        let totalSinceBoot = Date().timeIntervalSince(bootDate)
        return UptimeReading(
            uptimeSeconds: totalSinceBoot,
            awakeSeconds: uptime
        )
    }

    private func bootTime() -> Date {
        var bt = timeval()
        var size = MemoryLayout<timeval>.stride
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        sysctl(&mib, 2, &bt, &size, nil, 0)
        let seconds = TimeInterval(bt.tv_sec) + TimeInterval(bt.tv_usec) / 1_000_000
        return Date(timeIntervalSince1970: seconds)
    }
}
