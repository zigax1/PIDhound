import Foundation
import Darwin

public struct UptimeReading: Sendable, Equatable {
    public let uptimeSeconds: TimeInterval
    public let awakeSeconds: TimeInterval
}

public struct UptimeSampler: Sendable {
    public init() {}

    public func sample() -> UptimeReading {
        let awake = clockSeconds(CLOCK_UPTIME_RAW)
        let uptime = clockSeconds(CLOCK_MONOTONIC_RAW)
        return UptimeReading(uptimeSeconds: uptime, awakeSeconds: awake)
    }

    private func clockSeconds(_ clock: clockid_t) -> TimeInterval {
        var ts = timespec()
        clock_gettime(clock, &ts)
        return TimeInterval(ts.tv_sec) + TimeInterval(ts.tv_nsec) / 1_000_000_000
    }
}
