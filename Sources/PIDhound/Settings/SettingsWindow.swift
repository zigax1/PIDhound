import SwiftUI

public enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case general, appearance, shortcuts, powerUser, about

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .shortcuts: return "Shortcuts"
        case .powerUser: return "Power User"
        case .about: return "About"
        }
    }

    public var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "paintbrush"
        case .shortcuts: return "command"
        case .powerUser: return "bolt"
        case .about: return "info.circle"
        }
    }
}

public struct SettingsWindow: View {
    @Environment(\.theme) private var theme
    @Bindable var settings: SettingsStore
    public let shortcutsStore: ShortcutsStore

    @State private var selection: SettingsSection = .general

    public init(settings: SettingsStore, shortcutsStore: ShortcutsStore) {
        self.settings = settings
        self.shortcutsStore = shortcutsStore
    }

    public var body: some View {
        HStack(spacing: 0) {
            ThemedSidebar(items: sidebarItems, selection: $selection)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    detail
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(theme.background)
        }
        .background(theme.background)
        .foregroundStyle(theme.textPrimary)
    }

    private var sidebarItems: [ThemedSidebarItem<SettingsSection>] {
        SettingsSection.allCases.map {
            ThemedSidebarItem(id: $0, label: $0.label, systemImage: $0.systemImage)
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .general:    GeneralPane(settings: settings)
        case .appearance: AppearancePane(settings: settings)
        case .shortcuts:  ShortcutsPane(store: shortcutsStore)
        case .powerUser:  PowerUserPane(settings: settings)
        case .about:      AboutPane()
        }
    }
}
