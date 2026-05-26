import SwiftUI

public struct QuickRecapCard: View {
    @Environment(\.theme) private var theme
    public let staleCount: Int
    public let totalStaleRSS: UInt64
    public let onKillAll: () -> Void

    public init(staleCount: Int, totalStaleRSS: UInt64, onKillAll: @escaping () -> Void) {
        self.staleCount = staleCount
        self.totalStaleRSS = totalStaleRSS
        self.onKillAll = onKillAll
    }

    public var body: some View {
        if staleCount > 0 {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(theme.danger)
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(staleCount) stale item\(staleCount == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Using \(formatBytes(totalStaleRSS))")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                Button(action: onKillAll) {
                    Text("Kill all stale")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(.white)
                        .background(theme.danger)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(theme.danger.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.danger.opacity(0.3), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func formatBytes(_ b: UInt64) -> String {
        let gb = Double(b) / 1_073_741_824
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        let mb = Double(b) / 1_048_576
        return String(format: "%.0f MB", mb)
    }
}
