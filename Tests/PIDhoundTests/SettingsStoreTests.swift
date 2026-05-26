import Testing
import Foundation
@testable import PIDhound
@testable import Persistence

@Test func settingsStoreRoundtripTheme() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let store = try await SettingsStore(database: db)
    #expect(await store.selectedThemeId == "modern")
    await MainActor.run { store.selectedThemeId = "terminal-green" }
    let store2 = try await SettingsStore(database: db)
    #expect(await store2.selectedThemeId == "terminal-green")
}

@Test func settingsStoreOnboardingFlag() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let store = try await SettingsStore(database: db)
    #expect(await store.hasCompletedOnboarding == false)
    await MainActor.run { store.hasCompletedOnboarding = true }
    let store2 = try await SettingsStore(database: db)
    #expect(await store2.hasCompletedOnboarding == true)
}
