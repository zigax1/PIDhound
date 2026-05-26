import Foundation
import Observation
import Persistence

@Observable
@MainActor
public final class SettingsStore {
    private let database: Database

    public var selectedThemeId: String { didSet { try? persist("theme.selectedId", selectedThemeId) } }
    public var launchAtLogin: Bool {
        didSet {
            try? persist("general.launchAtLogin", launchAtLogin ? "1" : "0")
            LaunchAtLoginController.setEnabled(launchAtLogin)
        }
    }
    public var pollingIntervalSeconds: Int { didSet { try? persist("general.pollingIntervalSeconds", String(pollingIntervalSeconds)) } }
    public var hasCompletedOnboarding: Bool { didSet { try? persist("onboarding.completed", hasCompletedOnboarding ? "1" : "0") } }
    public var powerUserMode: Bool { didSet { try? persist("poweruser.enabled", powerUserMode ? "1" : "0") } }

    public init(database: Database) throws {
        self.database = database
        self.selectedThemeId = (try? SettingRecord.get("theme.selectedId", from: database)) ?? "modern"
        self.launchAtLogin = ((try? SettingRecord.get("general.launchAtLogin", from: database)) ?? "0") == "1"
        self.pollingIntervalSeconds = Int((try? SettingRecord.get("general.pollingIntervalSeconds", from: database)) ?? "2") ?? 2
        self.hasCompletedOnboarding = ((try? SettingRecord.get("onboarding.completed", from: database)) ?? "0") == "1"
        self.powerUserMode = ((try? SettingRecord.get("poweruser.enabled", from: database)) ?? "0") == "1"
    }

    private func persist(_ key: String, _ value: String) throws {
        try SettingRecord.set(key, value, into: database)
    }
}
