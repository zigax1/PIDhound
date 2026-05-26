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
    @Bindable var settings: SettingsStore
    public let shortcutsStore: ShortcutsStore

    @State private var selection: SettingsSection = .general

    public init(settings: SettingsStore, shortcutsStore: ShortcutsStore) {
        self.settings = settings
        self.shortcutsStore = shortcutsStore
    }

    public var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Label(section.label, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            detail
                .frame(minWidth: 480, idealWidth: 540)
                .navigationTitle(selection.label)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 720, minHeight: 500, idealHeight: 540)
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
