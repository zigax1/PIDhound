import SwiftUI
import Processes
import Grouping

public struct GroupCardView: View {
    @Environment(\.theme) private var theme
    public let group: Grouping.Group
    public let onKillProcess: (Int32) -> Void
    @State private var expanded: Bool = true
    @State private var hoveredPID: Int32?

    public init(group: Grouping.Group, onKillProcess: @escaping (Int32) -> Void) {
        self.group = group
        self.onKillProcess = onKillProcess
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if expanded {
                Divider().background(theme.border)
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(group.processes.sorted(by: { $0.snapshot.cpuPercent > $1.snapshot.cpuPercent }), id: \.snapshot.pid) { proc in
                        processRow(proc)
                    }
                }
            }
        }
        .background(theme.surface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var header: some View {
        Button(action: { withAnimation(.easeOut(duration: 0.15)) { expanded.toggle() } }) {
            HStack {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text(group.label)
                    .font(.system(size: 14, weight: .semibold))
                Text("(\(group.processes.count))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(theme.textSecondary)
                if group.staleCount > 0 {
                    StaleBadge(count: group.staleCount)
                }
                Spacer()
                Text("\(String(format: "%.1f", group.totalCPUPercent))%")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(theme.textSecondary)
                Text(formatBytes(group.totalRSSBytes))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func processRow(_ proc: ClassifiedProcess) -> some View {
        let isHovered = hoveredPID == proc.snapshot.pid
        return HStack(spacing: 8) {
            Text(proc.displayName)
                .font(.system(size: 12))
                .lineLimit(1)
            ForEach(proc.stateTags, id: \.self) { tag in
                stateTagChip(tag)
            }
            Spacer()
            Text("\(String(format: "%.1f", proc.snapshot.cpuPercent))%")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(theme.textSecondary)
            Text(formatBytes(proc.snapshot.residentSizeBytes))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(theme.textSecondary)
            Button(action: { onKillProcess(proc.snapshot.pid) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(isHovered ? theme.danger : theme.danger.opacity(0.65))
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .help("Kill PID \(proc.snapshot.pid)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .background(isHovered ? theme.rowHover : Color.clear)
        .onHover { hovering in
            hoveredPID = hovering ? proc.snapshot.pid : (hoveredPID == proc.snapshot.pid ? nil : hoveredPID)
        }
    }

    private func stateTagChip(_ tag: StateTag) -> some View {
        let (label, color): (String, Color) = {
            switch tag {
            case .active: return ("active", theme.success)
            case .idle: return ("idle", theme.warning)
            case .stale: return ("stale", theme.danger)
            case .orphan: return ("orphan", theme.danger)
            case .zombie: return ("zombie", theme.danger)
            }
        }()
        return Text(label)
            .font(.system(size: 9, weight: .semibold))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .foregroundStyle(color)
            .background(color.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(color.opacity(0.3), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    private func formatBytes(_ b: UInt64) -> String {
        let gb = Double(b) / 1_073_741_824
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        let mb = Double(b) / 1_048_576
        return String(format: "%.0f MB", mb)
    }
}
