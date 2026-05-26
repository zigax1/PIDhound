import Testing
import Foundation
import Yams
@testable import Processes

@Test func rulesFileParsesMinimalYAML() throws {
    let yaml = """
    version: 1
    groups:
      - id: claude-code-sessions
        label: Claude Code Sessions
        order: 1
        match:
          process_name: [claude]
        idle_threshold_minutes: 30
        stale_threshold_minutes: 120
    """
    let rules = try RulesFile.from(yaml: yaml)
    #expect(rules.version == 1)
    #expect(rules.groups.count == 1)
    #expect(rules.groups[0].id == "claude-code-sessions")
    #expect(rules.groups[0].label == "Claude Code Sessions")
    #expect(rules.groups[0].order == 1)
    #expect(rules.groups[0].match.processName == ["claude"])
    #expect(rules.groups[0].idleThresholdMinutes == 30)
    #expect(rules.groups[0].staleThresholdMinutes == 120)
}

@Test func rulesFileParsesArgvContains() throws {
    let yaml = """
    version: 1
    groups:
      - id: mcp-servers
        label: MCP Servers
        order: 2
        match:
          process_name: [node, npx]
          argv_contains: [mcp-server, /mcp/]
    """
    let rules = try RulesFile.from(yaml: yaml)
    #expect(rules.groups[0].match.argvContains == ["mcp-server", "/mcp/"])
}

@Test func bundledRulesFileLoadsAndHasGroups() throws {
    let rules = try RulesFile.loadBundled()
    #expect(rules.version == 1)
    #expect(rules.groups.count >= 7)
    #expect(rules.groups.contains(where: { $0.id == "claude-code-sessions" }))
}
