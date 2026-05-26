import SwiftUI
import AppKit
import Sensors
import Processes
import Grouping

public struct MenuBarDropdown: View {
    @Bindable var settings: SettingsStore

    public let vitals: VitalsSnapshot?
    public let actionableGroups: [Grouping.Group]
    public let staleCountActionable: Int
    public let staleCountOther: Int
    public let onOpenDashboard: () -> Void
    public let onOpenSettings: () -> Void
    public let onQuit: () -> Void

    public init(
        settings: SettingsStore,
        vitals: VitalsSnapshot?,
        actionableGroups: [Grouping.Group],
        staleCountActionable: Int,
        staleCountOther: Int,
        onOpenDashboard: @escaping () -> Void = {},
        onOpenSettings: @escaping () -> Void = {},
        onQuit: @escaping () -> Void
    ) {
        self.settings = settings
        self.vitals = vitals
        self.actionableGroups = actionableGroups
        self.staleCountActionable = staleCountActionable
        self.staleCountOther = staleCountOther
        self.onOpenDashboard = onOpenDashboard
        self.onOpenSettings = onOpenSettings
        self.onQuit = onQuit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if staleCountActionable > 0 {
                staleSection
                menuDivider
            }
            vitalsSection
            menuDivider
            groupsSection
            menuDivider
            actionsSection
        }
        .padding(.vertical, 5)
        .frame(width: 280)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .sheet(isPresented: $settings.hasCompletedOnboarding.toBindingInverse) {
            OnboardingSheet(settings: settings, onDone: {})
        }
    }

    private var menuDivider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(height: 1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
    }

    // MARK: - Sections

    private var staleSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.system(size: 12))
                Text("\(staleCountActionable) item\(staleCountActionable == 1 ? "" : "s") in dev/AI workflows")
                    .font(.system(size: 13))
            }
            if staleCountOther > 0 {
                Text("(plus \(staleCountOther) in system/other - hidden)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }

    private var vitalsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionLabel("VITALS")
            if let v = vitals {
                vitalRow("CPU", "\(String(format: "%.0f", v.cpuPercent))%")
                vitalRow("RAM", "\(formatGB(v.ramUsedBytes)) / \(formatGB(v.ramTotalBytes))")
                vitalRow("Thermal", v.thermalState.rawValue.capitalized,
                         valueColor: thermalColor(v.thermalState))
                vitalRow("Uptime", formatDuration(v.uptimeSeconds))
            } else {
                Text("Sampling...")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
            }
        }
        .padding(.vertical, 2)
    }

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionLabel("GROUPS")
            if actionableGroups.isEmpty {
                Text("No tracked groups active")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 1)
            } else {
                ForEach(actionableGroups, id: \.id) { group in
                    groupRow(group)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func groupRow(_ group: Grouping.Group) -> some View {
        HStack(spacing: 6) {
            Text(group.label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
            Spacer(minLength: 4)
            if group.staleCount > 0 {
                Text("\(group.staleCount)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color.red))
            }
            Text("\(group.processes.count)")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 2)
    }

    private var actionsSection: some View {
        VStack(spacing: 0) {
            ActionRow(
                title: "Open Dashboard",
                shortcut: "O",
                action: onOpenDashboard
            )
            SettingsActionRow(closePopover: onOpenSettings)
            ActionRow(
                title: "Quit PIDhound",
                shortcut: "Q",
                action: onQuit
            )
        }
        .padding(.vertical, 2)
    }

    // MARK: - Building blocks

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(0.5)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 14)
            .padding(.bottom, 2)
    }

    private func vitalRow(_ label: String, _ value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(valueColor ?? .secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 2)
    }

    // MARK: - Helpers

    private func thermalColor(_ state: ThermalState) -> Color {
        switch state {
        case .nominal: return .green
        case .moderate: return .orange
        case .heavy, .critical: return .red
        }
    }

    private func formatGB(_ bytes: UInt64) -> String {
        String(format: "%.1f GB", Double(bytes) / 1_073_741_824)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let days = total / 86_400
        let hours = (total % 86_400) / 3600
        let mins = (total % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }

}

// MARK: - ActionRow — NSMenu-style inset highlight on hover

private struct ActionRow: View {
    let title: String
    let shortcut: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13))
                Spacer(minLength: 8)
                Text("\u{2318}\(shortcut)")
                    .font(.system(size: 12))
                    .foregroundStyle(isHovered ? Color.white.opacity(0.85) : Color.secondary)
            }
            .foregroundStyle(isHovered ? Color.white : Color.primary)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(isHovered ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 5)
        .onHover { hovering in isHovered = hovering }
    }
}

// SettingsLink is the reliable way to open the SwiftUI Settings scene from an
// LSUIElement (menu-bar-only) app on macOS 14+. The AppKit `showSettingsWindow:`
// selector is flaky for accessory apps because the responder chain may not
// include the Settings scene host.
private struct SettingsActionRow: View {
    let closePopover: () -> Void

    @State private var isHovered = false

    var body: some View {
        SettingsLink {
            HStack(spacing: 8) {
                Text("Settings")
                    .font(.system(size: 13))
                Spacer(minLength: 8)
                Text("\u{2318},")
                    .font(.system(size: 12))
                    .foregroundStyle(isHovered ? Color.white.opacity(0.85) : Color.secondary)
            }
            .foregroundStyle(isHovered ? Color.white : Color.primary)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(isHovered ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 5)
        .onHover { hovering in isHovered = hovering }
        .simultaneousGesture(TapGesture().onEnded { closePopover() })
    }
}

private extension Binding where Value == Bool {
    var toBindingInverse: Binding<Bool> {
        Binding<Bool>(get: { !self.wrappedValue }, set: { self.wrappedValue = !$0 })
    }
}
