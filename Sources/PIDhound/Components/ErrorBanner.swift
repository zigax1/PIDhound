import SwiftUI

public struct ErrorBanner: View {
    @Environment(\.theme) private var theme
    public let message: String
    public let onDismiss: () -> Void

    public init(message: String, onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack {
            Image(systemName: "exclamationmark.octagon.fill")
                .foregroundStyle(theme.danger)
            Text(message)
                .font(.system(size: 12))
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(theme.danger.opacity(0.1))
        .overlay(Rectangle().frame(height: 1).foregroundStyle(theme.danger.opacity(0.3)), alignment: .bottom)
    }
}
