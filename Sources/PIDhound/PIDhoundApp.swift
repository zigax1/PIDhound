import SwiftUI
import AppKit
import Foundation
import Persistence
import PIDhoundCore
import Processes
import Shortcuts

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator {
    static var shared: AppCoordinator?

    let database: Persistence.Database
    let appState: AppState
    let settings: SettingsStore
    let shortcutsStore: ShortcutsStore
    let hotkeys = GlobalHotkeys()
    // Populated by DashboardSceneContent.onAppear so AppDelegate can open the window.
    var openDashboardAction: (() -> Void)?

    init() throws {
        let supportDir = SupportDirectory.resolveAndMigrate()
        let dbPath = "\(supportDir)/cockpit.sqlite"
        let db = try Persistence.Database.atPath(dbPath)
        try Migrations.runAll(on: db)
        self.database = db
        self.appState = try AppState(database: db)
        self.settings = try SettingsStore(database: db)
        self.shortcutsStore = try ShortcutsStore(database: db)
    }

    func registerHotkeys() {
        hotkeys.unregisterAll()
        for (i, s) in shortcutsStore.shortcuts.prefix(9).enumerated() {
            let shortcut = s
            hotkeys.register(cmdNumber: i + 1) {
                Task { @MainActor in
                    AppCoordinator.shared?.runShortcutFromHotkey(shortcut)
                }
            }
        }
    }

    // Hotkeys bypass confirmBeforeRun in v1.0 — a system-wide confirmation UI is v1.x work.
    func runShortcutFromHotkey(_ s: Shortcut) {
        let matched = ShortcutMatcher.resolve(s.match, against: appState.latestClassified)
        guard !matched.isEmpty else { return }
        Task {
            let outcomes = await ShortcutRunner.killAll(matched, gracePeriod: 2)
            for o in outcomes where o.success {
                let groupId = matched.first(where: { $0.snapshot.pid == o.pid })?.groupId
                try? ShortcutRecord.saveKillEvent(
                    pid: o.pid,
                    processName: o.processName,
                    groupId: groupId,
                    reason: "shortcut:\(s.id.uuidString)",
                    shortcutId: s.id.uuidString,
                    into: database
                )
            }
        }
    }
}

// MARK: - App

@main
struct PIDhoundApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // coordinator is initialised once in init() and held for the app's lifetime.
    // Individual @Observable stores are passed into scenes so SwiftUI can observe them.
    private let coordinator: AppCoordinator

    @State private var pendingShortcut: Shortcut?
    @State private var pendingMatches: [ClassifiedProcess] = []

    init() {
        do {
            let c = try AppCoordinator()
            self.coordinator = c
            AppCoordinator.shared = c
        } catch {
            fatalError("Failed to initialize PIDhound: \(error)")
        }
    }

    private var currentTheme: Theme {
        Theme.bundled.first(where: { $0.id == coordinator.settings.selectedThemeId }) ?? .modern
    }

    var body: some Scene {
        WindowGroup("PIDhound Dashboard", id: "dashboard") {
            DashboardSceneContent(
                coordinator: coordinator,
                pendingShortcut: $pendingShortcut,
                pendingMatches: $pendingMatches,
                currentTheme: currentTheme,
                onKillProcess: killOne,
                onKillAllStale: killAllStale,
                onRunShortcut: { runShortcut($0) },
                onPerformKill: { performKill(shortcut: $0, matched: $1) }
            )
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsWindow(
                settings: coordinator.settings,
                shortcutsStore: coordinator.shortcutsStore
            )
            .theme(currentTheme)
        }
    }

    // MARK: - Shortcut execution

    @MainActor
    private func runShortcut(_ s: Shortcut) {
        let matched = ShortcutMatcher.resolve(s.match, against: coordinator.appState.latestClassified)
        guard !matched.isEmpty else { return }
        if s.confirmBeforeRun {
            pendingShortcut = s
            pendingMatches = matched
        } else {
            performKill(shortcut: s, matched: matched)
        }
    }

    @MainActor
    private func performKill(shortcut: Shortcut, matched: [ClassifiedProcess]) {
        let shortcutId = shortcut.id.uuidString
        Task {
            let outcomes = await ShortcutRunner.killAll(matched, gracePeriod: 2)
            for o in outcomes where o.success {
                let groupId = matched.first(where: { $0.snapshot.pid == o.pid })?.groupId
                try? ShortcutRecord.saveKillEvent(
                    pid: o.pid,
                    processName: o.processName,
                    groupId: groupId,
                    reason: "shortcut:\(shortcutId)",
                    shortcutId: shortcutId,
                    into: coordinator.database
                )
            }
        }
    }

    // MARK: - Kill helpers

    @MainActor
    private func killOne(_ pid: Int32) {
        guard let proc = coordinator.appState.latestClassified.first(where: { $0.snapshot.pid == pid }) else { return }
        Task {
            let outcomes = await ShortcutRunner.killAll([proc], gracePeriod: 2)
            for o in outcomes where o.success {
                try? ShortcutRecord.saveKillEvent(
                    pid: o.pid,
                    processName: o.processName,
                    groupId: proc.groupId,
                    reason: "manual",
                    into: coordinator.database
                )
            }
        }
    }

    @MainActor
    private func killAllStale() {
        let stale = coordinator.appState.actionableGroups.flatMap { $0.processes }.filter {
            !$0.stateTags.isDisjoint(with: [.stale, .orphan, .zombie])
        }
        Task {
            let outcomes = await ShortcutRunner.killAll(stale, gracePeriod: 2)
            for o in outcomes where o.success {
                let groupId = stale.first(where: { $0.snapshot.pid == o.pid })?.groupId
                try? ShortcutRecord.saveKillEvent(
                    pid: o.pid,
                    processName: o.processName,
                    groupId: groupId,
                    reason: "quick-recap",
                    into: coordinator.database
                )
            }
        }
    }
}

// MARK: - Dashboard scene content view

// Extracted so we can use @Bindable on the @Observable settings store,
// which requires being inside a View body rather than a Scene body.
private struct DashboardSceneContent: View {
    @Environment(\.openWindow) private var openWindow

    let coordinator: AppCoordinator
    @Binding var pendingShortcut: Shortcut?
    @Binding var pendingMatches: [ClassifiedProcess]
    let currentTheme: Theme
    let onKillProcess: (Int32) -> Void
    let onKillAllStale: () -> Void
    let onRunShortcut: (Shortcut) -> Void
    let onPerformKill: (Shortcut, [ClassifiedProcess]) -> Void

    @Bindable private var settings: SettingsStore
    @Bindable private var appState: AppState

    init(
        coordinator: AppCoordinator,
        pendingShortcut: Binding<Shortcut?>,
        pendingMatches: Binding<[ClassifiedProcess]>,
        currentTheme: Theme,
        onKillProcess: @escaping (Int32) -> Void,
        onKillAllStale: @escaping () -> Void,
        onRunShortcut: @escaping (Shortcut) -> Void,
        onPerformKill: @escaping (Shortcut, [ClassifiedProcess]) -> Void
    ) {
        self.coordinator = coordinator
        self._pendingShortcut = pendingShortcut
        self._pendingMatches = pendingMatches
        self.currentTheme = currentTheme
        self.onKillProcess = onKillProcess
        self.onKillAllStale = onKillAllStale
        self.onRunShortcut = onRunShortcut
        self.onPerformKill = onPerformKill
        self._settings = Bindable(coordinator.settings)
        self._appState = Bindable(coordinator.appState)
    }

    var body: some View {
        DashboardWindow(
            appState: coordinator.appState,
            database: coordinator.database,
            onKillProcess: onKillProcess,
            onKillAllStale: onKillAllStale,
            shortcuts: coordinator.shortcutsStore.shortcuts,
            onRunShortcut: onRunShortcut
        )
        .theme(currentTheme)
        .sheet(isPresented: $settings.hasCompletedOnboarding.toBindingInverse) {
            OnboardingSheet(settings: coordinator.settings, onDone: {})
        }
        .confirmationDialog(
            "Run \"\(pendingShortcut?.name ?? "shortcut")\"?",
            isPresented: Binding(
                get: { pendingShortcut != nil },
                set: { if !$0 { pendingShortcut = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Kill \(pendingMatches.count) process\(pendingMatches.count == 1 ? "" : "es")", role: .destructive) {
                if let s = pendingShortcut {
                    onPerformKill(s, pendingMatches)
                }
                pendingShortcut = nil
            }
            Button("Cancel", role: .cancel) {
                pendingShortcut = nil
            }
        } message: {
            let names = pendingMatches.map { $0.displayName }.prefix(5).joined(separator: ", ")
            let suffix = pendingMatches.count > 5 ? "..." : ""
            Text("This will send SIGTERM (then SIGKILL after 2 s) to: \(names)\(suffix)")
        }
        .onAppear {
            // Register the openWindow action so AppDelegate can open this window
            // from the status bar menu without needing the SwiftUI environment.
            let open = openWindow
            coordinator.openDashboardAction = { open(id: "dashboard") }
        }
    }
}

// MARK: - AppDelegate

// Borderless NSPanel host so the dropdown has no arrow / chrome —
// SwiftUI inside paints the material background and rounded corners.
final class DropdownPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var dropdownPanel: DropdownPanel?
    private var dropdownEventMonitor: Any?
    private var dropdownResignObserver: NSObjectProtocol?
    private var statusButtonClickMonitor: Any?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let window = notification.object as? NSWindow,
                  window.title == "PIDhound Dashboard" else { return }
            NSApp.setActivationPolicy(.regular)
            // Intercept close so the X / Cmd+W hides the window instead of destroying it.
            if window.delegate !== self {
                window.delegate = self
            }
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard sender.title == "PIDhound Dashboard" else { return true }
        sender.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
        return false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let coordinator = AppCoordinator.shared else { return }

        buildStatusItem(coordinator: coordinator)
        buildDropdownPanel(coordinator: coordinator)

        let interval = TimeInterval(coordinator.settings.pollingIntervalSeconds)
        coordinator.appState.startSampling(intervalSeconds: interval)
        coordinator.registerHotkeys()

        // SwiftUI WindowGroup auto-creates the dashboard window on launch.
        // For a menu-bar utility we want zero visible windows until the user
        // explicitly opens Dashboard or Settings.
        DispatchQueue.main.async {
            for window in NSApp.windows where window.title == "PIDhound Dashboard" {
                window.orderOut(nil)
            }
            NSApp.setActivationPolicy(.accessory)
        }
    }

    private func buildStatusItem(coordinator: AppCoordinator) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }

        button.imagePosition = .imageLeft
        button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)

        // Swallow mouseDown on the status button before AppKit's own tracking
        // sees it. AppKit's default tracking auto-highlights on mouseDown and
        // un-highlights on mouseUp; returning nil here prevents tracking from
        // engaging at all, so we can drive the highlight ourselves without the
        // brief OFF flash that would otherwise sit between AppKit's unhighlight
        // and any deferred re-highlight.
        statusButtonClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return event }
            let eventWindow = event.window
            let isOurButton = MainActor.assumeIsolated {
                self.statusItem?.button?.window === eventWindow
            }
            guard isOurButton else { return event }
            MainActor.assumeIsolated { self.handleStatusButtonClick() }
            return nil
        }

        updateStatusLabel()
        startObservingAppState(coordinator: coordinator)
    }

    @MainActor
    private func handleStatusButtonClick() {
        if let panel = dropdownPanel, panel.isVisible {
            closeDropdown()
        } else {
            showDropdown()
        }
    }

    @MainActor
    private func updateStatusLabel() {
        guard let coordinator = AppCoordinator.shared, let button = statusItem.button else { return }
        let cpu = coordinator.appState.latestVitals?.cpuPercent
        let stale = coordinator.appState.staleCountActionable

        let symbolName = stale > 0 ? "exclamationmark.triangle.fill" : "cpu"
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config)

        let cpuText = cpu.map { " \(Int($0))%" } ?? ""
        let staleText = stale > 0 ? " · \(stale)" : ""
        button.title = cpuText + staleText
    }

    @MainActor
    private func startObservingAppState(coordinator: AppCoordinator) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateStatusLabel()
            }
        }
    }

    private func buildDropdownPanel(coordinator: AppCoordinator) {
        let dropdownView = StatusBarDropdownView(
            coordinator: coordinator,
            closePopover: { [weak self] in self?.closeDropdown() }
        )

        let panel = DropdownPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 100),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = NSHostingController(rootView: dropdownView)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.isMovable = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.isReleasedWhenClosed = false
        dropdownPanel = panel
    }

    private func showDropdown() {
        guard let panel = dropdownPanel,
              let button = statusItem.button,
              let buttonWindow = button.window else { return }

        // Let SwiftUI compute its natural size, then anchor below the status item.
        if let content = panel.contentView {
            panel.setContentSize(content.fittingSize)
        }
        let buttonRectInWindow = button.convert(button.bounds, to: nil)
        let buttonRectOnScreen = buttonWindow.convertToScreen(buttonRectInWindow)
        let panelSize = panel.frame.size
        let origin = NSPoint(
            x: buttonRectOnScreen.midX - panelSize.width / 2,
            y: buttonRectOnScreen.minY - panelSize.height - 4
        )
        panel.setFrameOrigin(origin)
        button.highlight(true)
        panel.orderFrontRegardless()
        panel.makeKey()
        installDropdownDismissalHooks()
    }

    func closeDropdown() {
        dropdownPanel?.orderOut(nil)
        statusItem.button?.highlight(false)
        removeDropdownDismissalHooks()
    }

    private func installDropdownDismissalHooks() {
        removeDropdownDismissalHooks()
        dropdownEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in self?.closeDropdown() }
        }
        dropdownResignObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.closeDropdown() }
        }
    }

    private func removeDropdownDismissalHooks() {
        if let monitor = dropdownEventMonitor {
            NSEvent.removeMonitor(monitor)
            dropdownEventMonitor = nil
        }
        if let observer = dropdownResignObserver {
            NotificationCenter.default.removeObserver(observer)
            dropdownResignObserver = nil
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// MARK: - Status bar host views

private struct StatusBarDropdownView: View {
    let coordinator: AppCoordinator
    @Bindable var appState: AppState
    @Bindable var settings: SettingsStore
    let closePopover: () -> Void

    init(coordinator: AppCoordinator, closePopover: @escaping () -> Void) {
        self.coordinator = coordinator
        self._appState = Bindable(coordinator.appState)
        self._settings = Bindable(coordinator.settings)
        self.closePopover = closePopover
    }

    var body: some View {
        MenuBarDropdown(
            settings: settings,
            vitals: appState.latestVitals,
            actionableGroups: appState.actionableGroups,
            staleCountActionable: appState.staleCountActionable,
            staleCountOther: appState.staleCountOther,
            onOpenDashboard: openDashboard,
            onOpenSettings: { closePopover() },
            onQuit: { NSApp.terminate(nil) }
        )
    }

    @MainActor
    private func openDashboard() {
        NSApp.activate(ignoringOtherApps: true)
        if let existing = NSApp.windows.first(where: { $0.title == "PIDhound Dashboard" }) {
            if existing.isMiniaturized { existing.deminiaturize(nil) }
            existing.makeKeyAndOrderFront(nil)
        } else {
            coordinator.openDashboardAction?()
        }
        closePopover()
    }
}

// MARK: - Helpers

private extension Binding where Value == Bool {
    var toBindingInverse: Binding<Bool> {
        Binding<Bool>(get: { !self.wrappedValue }, set: { self.wrappedValue = !$0 })
    }
}

private extension Array where Element == StateTag {
    func isDisjoint(with other: [StateTag]) -> Bool {
        Set(self).isDisjoint(with: Set(other))
    }
}
