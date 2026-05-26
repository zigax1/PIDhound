import Testing
import Foundation
import GRDB
@testable import PIDhoundCore
@testable import Persistence

@Test func engineProducesNonEmptyTickResult() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let engine = try SamplingEngine(database: db)

    _ = engine.tick()
    try await Task.sleep(for: .milliseconds(200))
    let result = engine.tick()

    #expect(result.vitals.ramTotalBytes > 0)
    #expect(result.groups.count >= 1)
}

@Test func enginePersistsToDB() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let engine = try SamplingEngine(database: db)
    _ = engine.tick()
    try await Task.sleep(for: .milliseconds(200))
    _ = engine.tickAndPersist()

    let vitalsCount = try db.read { conn in
        try Int.fetchOne(conn, sql: "SELECT COUNT(*) FROM vitals_sample") ?? 0
    }
    #expect(vitalsCount >= 1)
}
