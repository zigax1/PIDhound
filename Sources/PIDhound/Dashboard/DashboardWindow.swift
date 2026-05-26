import SwiftUI
import Persistence
import Processes
import Grouping
import Shortcuts

public struct DashboardWindow: View {
    @Environment(\.theme) private var theme
    @Bindable var appState: AppState
    public let database: Persistence.Database
    public let onKillProcess: (Int32) -> Void
    public let onKillAllStale: () -> Void
    public let shortcuts: [Shortcut]
    public let onRunShortcut: (Shortcut) -> Void

    @State private var selectedTab: Tab = .dashboard
    public enum Tab: String, CaseIterable, Identifiable {
        case dashboard, ports, history
        public var id: String { rawValue }
        public var label: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .ports: return "Ports"
            case .history: return "History"
            }
        }
    }

    public init(
        appState: AppState,
        database: Persistence.Database,
        onKillProcess: @escaping (Int32) -> Void,
        onKillAllStale: @escaping () -> Void,
        shortcuts: [Shortcut] = [],
        onRunShortcut: @escaping (Shortcut) -> Void = { _ in }
    ) {
        self.appState = appState
        self.database = database
        self.onKillProcess = onKillProcess
        self.onKillAllStale = onKillAllStale
        self.shortcuts = shortcuts
        self.onRunShortcut = onRunShortcut
    }

    public var body: some View {
        HStack(spacing: 0) {
            VitalsSidebar(vitals: appState.latestVitals)
            VStack(spacing: 0) {
                if let msg = appState.errorMessage {
                    ErrorBanner(message: msg, onDismiss: { appState.clearError() })
                }
                tabBar
                Divider().background(theme.border)
                content
            }
        }
        .background(theme.background)
        .foregroundStyle(theme.textPrimary)
        .frame(minWidth: 900, minHeight: 600)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.label)
                        .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(selectedTab == tab ? theme.textPrimary : theme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedTab == tab ? theme.surfaceElevated : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(selectedTab == tab ? theme.border : Color.clear, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.surface)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
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
