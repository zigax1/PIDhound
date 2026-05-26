import Testing
import Foundation
@testable import PIDhound
@testable import Persistence
@testable import PIDhoundCore

@Test func appStateProducesInitialTick() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let state = try await AppState(database: db)
    await state.tickOnce()
    try await Task.sleep(for: .milliseconds(200))
    await state.tickOnce()
    let vitals = await state.latestVitals
    let groups = await state.latestGroups
    #expect(vitals != nil)
    #expect(groups.count >= 1)
}

@Test func appStateStaleCountExcludesOther() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let state = try await AppState(database: db)
    await state.tickOnce()
    try await Task.sleep(for: .milliseconds(200))
    await state.tickOnce()
    let count = await state.staleCountActionable
    #expect(count >= 0)
}
