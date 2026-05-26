import Testing
import Foundation
@testable import Persistence

@Test func migrationsCreateAllTables() throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let tables = try db.read { conn in try conn.tableNames() }
    #expect(tables.contains("vitals_sample"))
    #expect(tables.contains("process_sample"))
    #expect(tables.contains("kill_event"))
    #expect(tables.contains("shortcut"))
    #expect(tables.contains("setting"))
}

@Test func migrationsAreIdempotent() throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    try Migrations.runAll(on: db)
    let tables = try db.read { conn in try conn.tableNames() }
    #expect(tables.contains("vitals_sample"))
}
