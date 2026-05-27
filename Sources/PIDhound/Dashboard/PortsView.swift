import SwiftUI
import Processes

public struct PortsView: View {
    @Environment(\.theme) private var theme
    public let classified: [ClassifiedProcess]
    public let onKillProcess: (Int32) -> Void

    @State private var ports: [ListeningPort] = []
    @State private var isLoading: Bool = true
    @State private var hoveredPID: Int32?

    public init(classified: [ClassifiedProcess], onKillProcess: @escaping (Int32) -> Void) {
        self.classified = classified
        self.onKillProcess = onKillProcess
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    Text("PORT").frame(width: 60, alignment: .leading)
                    Text("PROCESS").frame(maxWidth: .infinity, alignment: .leading)
                    Text("GROUP").frame(width: 120, alignment: .leading)
                    Text("PID").frame(width: 60, alignment: .leading)
                    Text("ACTION").frame(width: 70, alignment: .leading)
                }
                Button {
                    Task {
                        isLoading = true
                        ports = await Task.detached { PortLister.snapshot() }.value
                        isLoading = false
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.textSecondary)
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(theme.textTertiary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            Divider().background(theme.border)
            if isLoading {
                SkeletonRows(rowCount: 6, columnWidths: [60, nil, 120, 60, 70])
                    .padding(.top, 4)
            } else if ports.isEmpty {
                Text("No listening TCP ports detected.")
                    .font(.callout)
                    .foregroundStyle(theme.textSecondary)
                    .padding(20)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(portRows, id: \.id) { row in
                            portRowView(row)
                        }
                    }
                }
            }
        }
        .background(theme.background)
        .task {
            isLoading = true
            ports = await Task.detached { PortLister.snapshot() }.value
            isLoading = false
        }
    }

    private func portRowView(_ row: PortRow) -> some View {
        let isHovered = hoveredPID == row.pid
        return HStack {
            Text("\(row.port)")
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 60, alignment: .leading)
            Text(row.name)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            Text(row.group)
                .font(.system(size: 12))
                .foregroundStyle(theme.textSecondary)
                .frame(width: 120, alignment: .leading)
                .lineLimit(1)
            Text("\(row.pid)")
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 60, alignment: .leading)
            Button("Free") { onKillProcess(row.pid) }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .frame(width: 70, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .background(isHovered ? theme.rowHover : Color.clear)
        .onHover { hovering in
            hoveredPID = hovering ? row.pid : (hoveredPID == row.pid ? nil : hoveredPID)
        }
    }

    private struct PortRow: Identifiable {
        let id = UUID()
        let port: Int
        let name: String
        let group: String
        let pid: Int32
    }

    private var portRows: [PortRow] {
        let pidMap = Dictionary(uniqueKeysWithValues: classified.map { ($0.snapshot.pid, $0) })
        return ports.map { p in
            let proc = pidMap[p.pid]
            return PortRow(
                port: p.port,
                name: proc?.displayName ?? "(unknown)",
                group: proc?.groupId ?? "",
                pid: p.pid
            )
        }
    }
}
