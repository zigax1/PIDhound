import SwiftUI

public struct PowerUserPane: View {
    @Bindable var settings: SettingsStore
    public init(settings: SettingsStore) { self.settings = settings }

    public var body: some View {
        Form {
            Section {
                Toggle("Power User Mode", isOn: $settings.powerUserMode)
                Text("Unlocks AI analysis and advanced thermals. Coming in v2.0.")
                    .font(.caption).foregroundStyle(.secondary)
            } header: { Text("Power User Mode") }
            Section {
                Text("AI Provider, API key, model picker, and powermetrics setup will appear here when Power User Mode is enabled.")
                    .font(.caption).foregroundStyle(.secondary)
            } header: { Text("Coming in v2.0") }
        }
        .formStyle(.grouped)
        .padding(16)
    }
}
