import SwiftUI
import Persistence
import Processes
import Grouping
import Shortcuts

public struct DashboardWindow: View {
    @Environment(\.theme) private var theme
    @Bindable var appState: AppState
    public let database: Persistence.Database
    public let settings: SettingsStore
    public let shortcutsStore: ShortcutsStore
    public let onKillProcess: (Int32) -> Void
    public let onKillAllStale: () -> Void
    public let shortcuts: [Shortcut]
    public let onRunShortcut: (Shortcut) -> Void

    public init(
        appState: AppState,
        database: Persistence.Database,
        settings: SettingsStore,
        shortcutsStore: ShortcutsStore,
        onKillProcess: @escaping (Int32) -> Void,
        onKillAllStale: @escaping () -> Void,
        shortcuts: [Shortcut] = [],
        onRunShortcut: @escaping (Shortcut) -> Void = { _ in }
    ) {
        self.appState = appState
        self.database = database
        self.settings = settings
        self.shortcutsStore = shortcutsStore
        self.onKillProcess = onKillProcess
        self.onKillAllStale = onKillAllStale
        self.shortcuts = shortcuts
        self.onRunShortcut = onRunShortcut
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let msg = appState.errorMessage {
                ErrorBanner(message: msg, onDismiss: { appState.clearError() })
            }
            tabBar
            Divider().background(theme.border)
            HStack(spacing: 0) {
                if appState.selectedDashboardTab != .settings {
                    VitalsSidebar(vitals: appState.latestVitals)
                }
                content
            }
        }
        .background(theme.background)
        .foregroundStyle(theme.textPrimary)
        .frame(minWidth: 900, minHeight: 600)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(DashboardTab.allCases) { tab in
                tabButton(tab)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.surface)
    }

    private func tabButton(_ tab: DashboardTab) -> some View {
        let isSelected = appState.selectedDashboardTab == tab
        return Button(action: { appState.selectedDashboardTab = tab }) {
            Text(tab.label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? theme.surfaceElevated : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? theme.border : Color.clear, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @MainActor @ViewBuilder
    private var content: some View {
        switch appState.selectedDashboardTab {
        case .dashboard:
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        let staleRSS = appState.actionableGroups.flatMap { $0.processes }.filter { !$0.stateTags.isDisjoint(with: [.stale, .orphan, .zombie]) }.reduce(UInt64(0)) { $0 + $1.snapshot.residentSizeBytes }
                        QuickRecapCard(staleCount: appState.staleCountActionable, totalStaleRSS: staleRSS, onKillAll: onKillAllStale)
                        GroupListView(
                            actionableGroups: appState.actionableGroups,
                            otherGroup: appState.otherGroup,
                            onKillProcess: onKillProcess
                        )
                    }
                    .padding(16)
                }
                if !shortcuts.isEmpty {
                    Divider().background(theme.border)
                    ShortcutsBar(shortcuts: shortcuts, onRun: onRunShortcut)
                }
            }
        case .ports:
            PortsView(classified: appState.latestClassified, onKillProcess: onKillProcess)
        case .history:
            HistoryView(database: database)
        case .settings:
            SettingsWindow(settings: settings, shortcutsStore: shortcutsStore)
        }
    }
}

private extension Set where Element == StateTag {
    func isDisjoint(with other: [StateTag]) -> Bool {
        self.isDisjoint(with: Set(other))
    }
}

private extension Array where Element == StateTag {
    func isDisjoint(with other: Set<StateTag>) -> Bool {
        Set(self).isDisjoint(with: other)
    }
}
