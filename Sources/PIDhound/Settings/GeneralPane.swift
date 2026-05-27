import SwiftUI

public struct GeneralPane: View {
    @Bindable var settings: SettingsStore
    public init(settings: SettingsStore) { self.settings = settings }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSection("Behavior") {
                ThemedToggle(
                    "Launch at login",
                    helper: "Start PIDhound automatically when you log in.",
                    isOn: $settings.launchAtLogin
                )
                ThemedSegmentedPicker(
                    "Polling interval",
                    helper: "How often vitals and processes are sampled.",
                    selection: $settings.pollingIntervalSeconds,
                    options: [(1, "1s"), (2, "2s"), (5, "5s")]
                )
            }
        }
    }
}
