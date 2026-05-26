import Testing
import Foundation
@testable import Shortcuts
@testable import Processes

@Test func killOutcomeHasExpectedShape() async throws {
    // Spawn a sleep process we can kill
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sleep")
    p.arguments = ["30"]
    try p.run()
    let pid = p.processIdentifier
    #expect(pid > 0)

    let snap = ProcessSnapshot(
        pid: pid, ppid: getppid(), name: "sleep",
        executablePath: "/bin/sleep", argv: ["sleep", "30"],
        cwd: nil, cpuPercent: 0, residentSizeBytes: 0,
        startTime: Date()
    )
    let classified = ClassifiedProcess(snapshot: snap, groupId: "other", stateTags: [])

    let outcomes = await ShortcutRunner.killAll([classified], gracePeriod: 0.5)
    #expect(outcomes.count == 1)
    #expect(outcomes[0].pid == pid)
    #expect(outcomes[0].success == true)

    // Verify sleep is dead
    p.waitUntilExit()
    #expect(p.isRunning == false)
}
