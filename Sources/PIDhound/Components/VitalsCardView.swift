import SwiftUI

public struct VitalsCardView: View {
    @Environment(\.theme) private var theme

    public let label: String
    public let value: String
    public let unit: String?
    public let valueColor: Color?

    public init(label: String, value: String, unit: String? = nil, valueColor: Color? = nil) {
        self.label = label
        self.value = value
        self.unit = unit
        self.valueColor = valueColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(theme.textTertiary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(valueColor ?? theme.textPrimary)
                if let unit {
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
