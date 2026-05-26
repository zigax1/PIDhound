import Testing
import Foundation
@testable import Processes

@Test func processSnapshotIsCodable() throws {
    let snap = ProcessSnapshot(
        pid: 1234, ppid: 1, name: "node",
        executablePath: "/usr/local/bin/node",
        argv: ["node", "/path/to/mcp-server.js"],
        cwd: "/Users/alice/repo",
        cpuPercent: 12.5, residentSizeBytes: 268_435_456,
        startTime: Date(timeIntervalSince1970: 1_700_000_000)
    )
    let encoded = try JSONEncoder().encode(snap)
    let decoded = try JSONDecoder().decode(ProcessSnapshot.self, from: encoded)
    #expect(decoded == snap)
}
