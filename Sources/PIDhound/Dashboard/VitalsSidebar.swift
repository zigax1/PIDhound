import SwiftUI
import Sensors

public struct VitalsSidebar: View {
    @Environment(\.theme) private var theme
    public let vitals: VitalsSnapshot?

    public init(vitals: VitalsSnapshot?) { self.vitals = vitals }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let v = vitals {
                VitalsCardView(label: "CPU", value: "\(Int(v.cpuPercent))", unit: "%",
                               valueColor: v.cpuPercent > 80 ? theme.danger : v.cpuPercent > 50 ? theme.warning : theme.textPrimary)
                VitalsCardView(label: "RAM", value: String(format: "%.1f", Double(v.ramUsedBytes) / 1_073_741_824),
                               unit: " / \(String(format: "%.0f", Double(v.ramTotalBytes) / 1_073_741_824)) GB")
                VitalsCardView(label: "Thermal", value: v.thermalState.rawValue.capitalized,
                               valueColor: thermalColor(v.thermalState))
                VitalsCardView(label: "Uptime", value: formatDuration(v.uptimeSeconds))
            } else {
                Text("Sampling vitals...")
                    .foregroundStyle(theme.textTertiary)
            }
            Spacer()
        }
        .padding(12)
        .frame(width: 220)
        .background(theme.surface)
    }

    private func thermalColor(_ s: ThermalState) -> Color {
        switch s {
        case .nominal: return theme.success
        case .moderate: return theme.warning
        case .heavy, .critical: return theme.danger
        }
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
