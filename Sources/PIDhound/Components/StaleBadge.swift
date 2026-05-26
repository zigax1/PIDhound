import SwiftUI

public struct StaleBadge: View {
    @Environment(\.theme) private var theme

    public let count: Int
    public let label: String

    public init(count: Int, label: String = "stale") {
        self.count = count
        self.label = label
    }

    public var body: some View {
        if count > 0 {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 10, weight: .semibold))
                Text("\(count) \(label)")
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(theme.danger)
            .background(theme.danger.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(theme.danger.opacity(0.3), lineWidth: 1))
        }
    }
}
