import SwiftUI
import Shortcuts

public struct ShortcutsBar: View {
    @Environment(\.theme) private var theme
    public let shortcuts: [Shortcut]
    public let onRun: (Shortcut) -> Void

    public init(shortcuts: [Shortcut], onRun: @escaping (Shortcut) -> Void) {
        self.shortcuts = shortcuts
        self.onRun = onRun
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Text("Shortcuts")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.leading, 4)
                ForEach(shortcuts) { s in
                    Button(action: { onRun(s) }) {
                        HStack(spacing: 6) {
                            Text(s.name)
                                .font(.system(size: 12))
                            if let kb = s.keybind {
                                Text(formatKeybind(kb))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(theme.textTertiary)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(theme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.border, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(theme.surface.opacity(0.5))
    }

    private func formatKeybind(_ kb: String) -> String {
        kb.lowercased()
            .replacingOccurrences(of: "cmd+", with: "\u{2318}")
            .uppercased()
    }
}
