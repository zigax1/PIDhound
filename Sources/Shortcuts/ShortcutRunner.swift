import Foundation
import Darwin
import Processes

public struct KillOutcome: Sendable {
    public let pid: Int32
    public let processName: String
    public let success: Bool
    public let error: String?
}

public enum ShortcutRunner {
    /// Send SIGTERM to each pid. Wait `gracePeriod` seconds. Send SIGKILL to any survivors.
    public static func killAll(_ matched: [ClassifiedProcess], gracePeriod: TimeInterval = 3) async -> [KillOutcome] {
        var outcomes: [KillOutcome] = []

        // Phase 1: SIGTERM
        for c in matched {
            let r = Darwin.kill(c.snapshot.pid, SIGTERM)
            if r == 0 {
                outcomes.append(KillOutcome(pid: c.snapshot.pid, processName: c.snapshot.name, success: true, error: nil))
            } else {
                let err = String(cString: strerror(errno))
                outcomes.append(KillOutcome(pid: c.snapshot.pid, processName: c.snapshot.name, success: false, error: err))
            }
        }

        // Phase 2: wait, then SIGKILL survivors
        try? await Task.sleep(for: .seconds(gracePeriod))

        for i in outcomes.indices where outcomes[i].success {
            // Check if process still alive (kill with signal 0)
            if Darwin.kill(outcomes[i].pid, 0) == 0 {
                // Still alive — escalate
                _ = Darwin.kill(outcomes[i].pid, SIGKILL)
            }
        }

        return outcomes
    }
}
