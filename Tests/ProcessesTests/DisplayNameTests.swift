import Testing
import Foundation
@testable import Processes

@Test func displayNameFallsBackForVersionString() {
    let snap = ProcessSnapshot(pid: 1, ppid: 1, name: "2.1.145",
        executablePath: "/usr/local/bin/claude", argv: ["claude"],
        cwd: nil, cpuPercent: 0, residentSizeBytes: 0, startTime: Date())
    let cp = ClassifiedProcess(snapshot: snap, groupId: "claude-code-sessions", stateTags: [])
    #expect(cp.displayName == "claude")
}

@Test func displayNameUsesRawNameNormally() {
    let snap = ProcessSnapshot(pid: 1, ppid: 1, name: "node",
        executablePath: "/usr/local/bin/node", argv: ["node"],
        cwd: nil, cpuPercent: 0, residentSizeBytes: 0, startTime: Date())
    let cp = ClassifiedProcess(snapshot: snap, groupId: "mcp-servers", stateTags: [])
    #expect(cp.displayName == "node")
}
