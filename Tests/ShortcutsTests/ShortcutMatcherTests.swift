import Testing
import Foundation
@testable import Shortcuts
@testable import Processes

private func cp(pid: Int32, ppid: Int32 = 1, name: String, group: String, tags: [StateTag] = [], argv: [String] = []) -> ClassifiedProcess {
    ClassifiedProcess(
        snapshot: ProcessSnapshot(pid: pid, ppid: ppid, name: name, executablePath: "/bin/\(name)", argv: argv, cwd: nil, cpuPercent: 0, residentSizeBytes: 100, startTime: Date()),
        groupId: group, stateTags: tags
    )
}

@Test func matchesGroupWithoutTagFilter() {
    let procs = [cp(pid: 1, name: "a", group: "mcp"), cp(pid: 2, name: "b", group: "claude")]
    let result = ShortcutMatcher.resolve(.group(id: "mcp", tagsAny: []), against: procs)
    #expect(result.count == 1)
    #expect(result[0].snapshot.pid == 1)
}

@Test func matchesGroupWithTagFilter() {
    let procs = [cp(pid: 1, name: "a", group: "mcp", tags: [.orphan]), cp(pid: 2, name: "b", group: "mcp")]
    let result = ShortcutMatcher.resolve(.group(id: "mcp", tagsAny: [.orphan]), against: procs)
    #expect(result.count == 1)
    #expect(result[0].snapshot.pid == 1)
}

@Test func matchesNamePattern() {
    let procs = [cp(pid: 1, name: "claude", group: "claude"), cp(pid: 2, name: "node", group: "mcp")]
    let result = ShortcutMatcher.resolve(.namePattern("clau"), against: procs)
    #expect(result.count == 1)
    #expect(result[0].snapshot.pid == 1)
}

@Test func matchesPortInArgv() {
    let procs = [
        cp(pid: 1, name: "vite", group: "dev", argv: ["vite", "--port", ":5173"]),
        cp(pid: 2, name: "next", group: "dev", argv: ["next", "dev"])
    ]
    let result = ShortcutMatcher.resolve(.port(5173), against: procs)
    #expect(result.count == 1)
    #expect(result[0].snapshot.pid == 1)
}
