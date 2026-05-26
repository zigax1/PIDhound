import SwiftUI

public struct AppearancePane: View {
    @Bindable var settings: SettingsStore
    public init(settings: SettingsStore) { self.settings = settings }

    public var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $settings.selectedThemeId) {
                    ForEach(Theme.bundled, id: \.id) { theme in
                        Text(theme.displayName).tag(theme.id)
                    }
                }
                .pickerStyle(.inline)
            } header: { Text("Theme") }
        }
        .formStyle(.grouped)
        .padding(16)
    }
}
