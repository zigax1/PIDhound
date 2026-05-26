import Testing
import Foundation
@testable import Processes

private func snap(name: String, argv: [String] = [], pid: Int32 = 1, ppid: Int32 = 1) -> ProcessSnapshot {
    ProcessSnapshot(
        pid: pid, ppid: ppid, name: name,
        executablePath: "/usr/bin/\(name)", argv: argv,
        cwd: nil, cpuPercent: 5, residentSizeBytes: 100_000_000,
        startTime: Date(timeIntervalSinceNow: -120)
    )
}

private let testRules = try! RulesFile.from(yaml: """
version: 1
groups:
  - id: claude-code-sessions
    label: Claude
    order: 1
    match:
      process_name: [claude]
  - id: mcp-servers
    label: MCP
    order: 2
    match:
      process_name: [node]
      argv_contains: [mcp-server]
  - id: other
    label: Other
    order: 99
    match:
      process_name: []
""")

@Test func classifierAssignsClaudeByName() {
    let classifier = Classifier(rules: testRules)
    let result = classifier.classify(processes: [snap(name: "claude", pid: 100)], activity: ProcessActivityTracker())
    #expect(result.count == 1)
    #expect(result[0].groupId == "claude-code-sessions")
}

@Test func classifierAssignsMCPByArgv() {
    let classifier = Classifier(rules: testRules)
    let result = classifier.classify(processes: [snap(name: "node", argv: ["node", "/path/to/mcp-server.js"], pid: 200)], activity: ProcessActivityTracker())
    #expect(result.count == 1)
    #expect(result[0].groupId == "mcp-servers")
}

@Test func classifierFallsBackToOther() {
    let classifier = Classifier(rules: testRules)
    let result = classifier.classify(processes: [snap(name: "unknown-binary", pid: 300)], activity: ProcessActivityTracker())
    #expect(result.count == 1)
    #expect(result[0].groupId == "other")
}
