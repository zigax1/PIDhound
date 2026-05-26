import Foundation

public final class ProcessActivityTracker: @unchecked Sendable {
    private var lastActiveAt: [Int32: Date] = [:]

    public init() {}

    public func record(processes: [ProcessSnapshot], at now: Date = Date()) {
        for p in processes where p.cpuPercent > 1 {
            lastActiveAt[p.pid] = now
        }
    }

    public func idleSeconds(pid: Int32, now: Date = Date()) -> TimeInterval {
        guard let last = lastActiveAt[pid] else { return 0 }
        return now.timeIntervalSince(last)
    }

    public func pruneDead(livePIDs: Set<Int32>) {
        lastActiveAt = lastActiveAt.filter { livePIDs.contains($0.key) }
    }
}
