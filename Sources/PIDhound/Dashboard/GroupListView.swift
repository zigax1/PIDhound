import SwiftUI
import Grouping

public struct GroupListView: View {
    @Environment(\.theme) private var theme
    public let actionableGroups: [Grouping.Group]
    public let otherGroup: Grouping.Group?
    public let onKillProcess: (Int32) -> Void
    @State private var otherExpanded: Bool = false

    public init(
        actionableGroups: [Grouping.Group],
        otherGroup: Grouping.Group?,
        onKillProcess: @escaping (Int32) -> Void
    ) {
        self.actionableGroups = actionableGroups
        self.otherGroup = otherGroup
        self.onKillProcess = onKillProcess
    }

    public var body: some View {
        VStack(spacing: 8) {
            ForEach(actionableGroups, id: \.id) { group in
                GroupCardView(group: group, onKillProcess: onKillProcess)
            }
            if let other = otherGroup, !other.processes.isEmpty {
                Button(action: { withAnimation { otherExpanded.toggle() } }) {
                    HStack {
                        Image(systemName: otherExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                        Text("System / Other (\(other.processes.count))")
                            .font(.system(size: 13))
                        Spacer()
                        Text("\(String(format: "%.1f", other.totalCPUPercent))%")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    .foregroundStyle(theme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if otherExpanded {
                    GroupCardView(group: other, onKillProcess: onKillProcess)
                }
            }
        }
    }
}
