import SwiftUI

public struct ThemedRow<Leading: View, Trailing: View>: View {
    @Environment(\.theme) private var theme
    public let label: String
    public let helper: String?
    public let leading: () -> Leading
    public let trailing: () -> Trailing

    public init(
        _ label: String,
        helper: String? = nil,
        @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.label = label
        self.helper = helper
        self.leading = leading
        self.trailing = trailing
    }

    public var body: some View {
        HStack(spacing: 10) {
            leading()
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(theme.textPrimary)
                if let helper {
                    Text(helper)
                        .font(.system(size: 11))
                        .foregroundStyle(theme.textSecondary)
                }
            }
            Spacer()
            trailing()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
}
