import Testing
import Foundation
@testable import Grouping
@testable import Processes

private func cp(pid: Int32, group: String, cpu: Double = 5, rss: UInt64 = 100_000_000, tags: [StateTag] = []) -> ClassifiedProcess {
    let snap = ProcessSnapshot(
        pid: pid, ppid: 1, name: "p\(pid)",
        executablePath: "/bin/p\(pid)", argv: [],
        cwd: nil, cpuPercent: cpu, residentSizeBytes: rss,
        startTime: Date()
    )
    return ClassifiedProcess(snapshot: snap, groupId: group, stateTags: tags)
}

private let testRules = try! RulesFile.from(yaml: """
version: 1
groups:
  - id: claude-code-sessions
    label: Claude Code Sessions
    order: 1
    match: { process_name: [] }
  - id: mcp-servers
    label: MCP Servers
    order: 2
    match: { process_name: [] }
  - id: other
    label: Other
    order: 99
    match: { process_name: [] }
""")

@Test func builderAggregatesByGroup() {
    let builder = GroupBuilder(rules: testRules)
    let input = [
        cp(pid: 1, group: "claude-code-sessions", cpu: 10, rss: 100),
        cp(pid: 2, group: "claude-code-sessions", cpu: 20, rss: 200),
        cp(pid: 3, group: "mcp-servers", cpu: 5, rss: 50),
    ]
    let groups = builder.build(from: input)
    #expect(groups.count >= 2)
    let claude = groups.first(where: { $0.id == "claude-code-sessions" })!
    #expect(claude.processes.count == 2)
    #expect(claude.totalCPUPercent == 30)
    #expect(claude.totalRSSBytes == 300)
}

@Test func builderRespectsOrder() {
    let builder = GroupBuilder(rules: testRules)
    let input = [
        cp(pid: 1, group: "mcp-servers"),
        cp(pid: 2, group: "claude-code-sessions"),
    ]
    let groups = builder.build(from: input)
    #expect(groups.first?.id == "claude-code-sessions")
}

@Test func staleCountIsCorrect() {
    let builder = GroupBuilder(rules: testRules)
    let input = [
        cp(pid: 1, group: "mcp-servers", tags: [.orphan]),
        cp(pid: 2, group: "mcp-servers", tags: [.stale]),
        cp(pid: 3, group: "mcp-servers", tags: []),
    ]
    let groups = builder.build(from: input)
    let mcp = groups.first(where: { $0.id == "mcp-servers" })!
    #expect(mcp.staleCount == 2)
}
