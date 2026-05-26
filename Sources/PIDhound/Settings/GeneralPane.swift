import SwiftUI

public struct GeneralPane: View {
    @Bindable var settings: SettingsStore
    public init(settings: SettingsStore) { self.settings = settings }

    public var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Picker("Polling interval", selection: $settings.pollingIntervalSeconds) {
                    Text("1 second").tag(1)
                    Text("2 seconds").tag(2)
                    Text("5 seconds").tag(5)
                }
            } header: { Text("Behavior") }
        }
        .formStyle(.grouped)
        .padding(16)
    }
}
