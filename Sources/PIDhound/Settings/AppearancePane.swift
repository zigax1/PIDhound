import SwiftUI

public struct AppearancePane: View {
    @Environment(\.theme) private var theme
    @Bindable var settings: SettingsStore
    public init(settings: SettingsStore) { self.settings = settings }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSection("Theme") {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 140), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(Theme.bundled, id: \.id) { t in
                        swatch(for: t)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }
        }
    }

    private func swatch(for t: Theme) -> some View {
        let isSelected = settings.selectedThemeId == t.id
        return Button(action: { settings.selectedThemeId = t.id }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Rectangle().fill(t.background)
                    Rectangle().fill(t.surface)
                    Rectangle().fill(t.accent)
                }
                .frame(height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(t.border, lineWidth: 0.5))
                Text(t.displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(theme.textPrimary)
            }
            .padding(8)
            .background(theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? theme.accent : theme.border, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
