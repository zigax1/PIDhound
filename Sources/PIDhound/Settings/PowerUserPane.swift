import SwiftUI

public struct PowerUserPane: View {
    @Environment(\.theme) private var theme
    @Bindable var settings: SettingsStore
    public init(settings: SettingsStore) { self.settings = settings }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSection("Power User Mode") {
                ThemedToggle(
                    "Power User Mode",
                    helper: "Unlocks AI analysis and advanced thermals. Coming in v2.0.",
                    isOn: $settings.powerUserMode
                )
            }

            ThemedSection {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.textTertiary)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Coming in v2.0")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary)
                        Text("AI Provider, API key, model picker, and powermetrics setup will appear here when Power User Mode is enabled.")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
            }
            .opacity(0.7)
        }
    }
}
