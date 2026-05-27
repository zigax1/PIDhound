import SwiftUI

public struct ThemedSection<Content: View, Trailing: View>: View {
    @Environment(\.theme) private var theme
    public let title: String?
    public let trailing: () -> Trailing
    public let content: () -> Content

    public init(
        _ title: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.trailing = trailing
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if title != nil || !(trailing() is EmptyView) {
                HStack {
                    if let title {
                        Text(title.uppercased())
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(theme.textTertiary)
                            .tracking(0.6)
                    }
                    Spacer()
                    trailing()
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(theme.surface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
