import Testing
import Foundation
import Sensors
import Processes
@testable import Persistence

@Test func databaseOpensInMemory() throws {
    let db = try Database.inMemory()
    let tables = try db.read { conn in
        try conn.tableNames()
    }
    #expect(tables.isEmpty)
}

@Test func insertAndFetchVitalsSample() throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)

    let snap = VitalsSnapshot(
        timestamp: Date(timeIntervalSince1970: 1_700_000_000),
        cpuPercent: 74.5, ramUsedBytes: 21_400_000_000,
        ramTotalBytes: 34_359_738_368, thermalState: .moderate,
        uptimeSeconds: 2_000_000, awakeSeconds: 30_000
    )
    try VitalsSampleRecord.insert(snapshot: snap, into: db)

    let count = try db.read { conn in
        try Int.fetchOne(conn, sql: "SELECT COUNT(*) FROM vitals_sample") ?? 0
    }
    #expect(count == 1)
}

@Test func insertAndFetchProcessSamples() throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)

    let now = Date(timeIntervalSince1970: 1_700_000_100)
    let snap = ProcessSnapshot(
        pid: 4242, ppid: 1, name: "claude",
        executablePath: "/usr/local/bin/claude", argv: ["claude"],
        cwd: "/Users/alice", cpuPercent: 12.5, residentSizeBytes: 250_000_000,
        startTime: now
    )
    let classified = ClassifiedProcess(snapshot: snap, groupId: "claude-code-sessions", stateTags: [.active])
    try ProcessSampleRecord.insert(classified: [classified], timestamp: now, into: db)

    let count = try db.read { conn in
        try Int.fetchOne(conn, sql: "SELECT COUNT(*) FROM process_sample WHERE pid=4242") ?? 0
    }
    #expect(count == 1)
}
