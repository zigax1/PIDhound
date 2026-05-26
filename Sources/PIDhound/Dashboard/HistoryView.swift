import SwiftUI
import Charts
import Persistence
import GRDB

public struct HistoryView: View {
    @Environment(\.theme) private var theme
    public let database: Persistence.Database

    @State private var vitalsHistory: [VitalsPoint] = []
    @State private var killEvents: [KillEvent] = []

    public init(database: Persistence.Database) {
        self.database = database
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Last 24 hours")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)

                if vitalsHistory.isEmpty {
                    Text("No history yet. Run for a while and check back.")
                        .font(.callout)
                        .foregroundStyle(theme.textTertiary)
                } else {
                    Chart(vitalsHistory) { point in
                        LineMark(x: .value("Time", point.time), y: .value("CPU", point.cpu))
                            .foregroundStyle(theme.accent)
                    }
                    .frame(height: 160)
                }

                Divider().background(theme.border)
                Text("Kill events (last 50)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
                if killEvents.isEmpty {
                    Text("No kills recorded yet.")
                        .font(.callout)
                        .foregroundStyle(theme.textTertiary)
                } else {
                    ForEach(killEvents) { ev in
                        HStack {
                            Text(ev.time, style: .relative)
                                .font(.system(size: 12))
                                .foregroundStyle(theme.textSecondary)
                            Text(ev.processName)
                                .font(.system(size: 12, design: .monospaced))
                            Spacer()
                            Text(ev.reason)
                                .font(.caption)
                                .foregroundStyle(theme.textTertiary)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(theme.background)
        .task {
            await loadHistory()
        }
    }

    public struct VitalsPoint: Identifiable {
        public let id = UUID()
        public let time: Date
        public let cpu: Double
    }

    public struct KillEvent: Identifiable {
        public let id: Int64
        public let time: Date
        public let processName: String
        public let reason: String
    }

    private func loadHistory() async {
        do {
            let cutoff = Int(Date().addingTimeInterval(-86_400).timeIntervalSince1970)
            let vitals = try database.read { db -> [VitalsPoint] in
                let rows = try Row.fetchAll(db, sql: "SELECT ts, cpu_pct FROM vitals_sample WHERE ts > ? ORDER BY ts ASC", arguments: [cutoff])
                return rows.map { row in
                    VitalsPoint(
                        time: Date(timeIntervalSince1970: TimeInterval(row["ts"] as Int64? ?? 0)),
                        cpu: row["cpu_pct"] as Double? ?? 0
                    )
                }
            }
            let events = try database.read { db -> [KillEvent] in
                let rows = try Row.fetchAll(db, sql: "SELECT id, ts, process_name, reason FROM kill_event ORDER BY ts DESC LIMIT 50")
                return rows.map { row in
                    KillEvent(
                        id: row["id"] as Int64? ?? 0,
                        time: Date(timeIntervalSince1970: TimeInterval(row["ts"] as Int64? ?? 0)),
                        processName: row["process_name"] as String? ?? "?",
                        reason: row["reason"] as String? ?? ""
                    )
                }
            }
            vitalsHistory = vitals
            killEvents = events
        } catch {
            // ignore for v1
        }
    }
}
