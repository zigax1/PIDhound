import SwiftUI

public struct KillButton: View {
    @Environment(\.theme) private var theme
    public let pid: Int32
    public let tooltip: String
    public let action: () -> Void
    @State private var isHovered: Bool = false

    public init(pid: Int32, tooltip: String? = nil, action: @escaping () -> Void) {
        self.pid = pid
        self.tooltip = tooltip ?? "Kill PID \(pid)"
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(isHovered ? theme.danger : theme.danger.opacity(0.65))
                .font(.system(size: 13))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(tooltip)
    }
}
