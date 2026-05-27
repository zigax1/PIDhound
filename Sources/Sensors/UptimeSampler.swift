import Foundation
import Darwin

public struct UptimeReading: Sendable, Equatable {
    public let uptimeSeconds: TimeInterval
    public let awakeSeconds: TimeInterval
}

public struct UptimeSampler: Sendable {
    public init() {}

    public func sample() -> UptimeReading {
        return UptimeReading(
            uptimeSeconds: clockSeconds(CLOCK_MONOTONIC_RAW),
            awakeSeconds: clockSeconds(CLOCK_UPTIME_RAW)
        )
    }

    private func clockSeconds(_ clock: clockid_t) -> TimeInterval {
        var ts = timespec()
        clock_gettime(clock, &ts)
        return TimeInterval(ts.tv_sec) + TimeInterval(ts.tv_nsec) / 1_000_000_000
    }
}
