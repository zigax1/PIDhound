import SwiftUI
import Shortcuts

public struct ShortcutsPane: View {
    @Environment(\.theme) private var theme
    @Bindable var store: ShortcutsStore
    @State private var selectedId: UUID?
    @State private var hoveredId: UUID?

    public init(store: ShortcutsStore) { self.store = store }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSection("Shortcuts") {
                VStack(spacing: 0) {
                    ForEach(store.shortcuts) { s in
                        row(for: s)
                    }
                    Divider().background(theme.border).padding(.vertical, 4)
                    footer
                }
            }
        }
    }

    private func row(for s: Shortcut) -> some View {
        let isSelected = selectedId == s.id
        let isHovered = hoveredId == s.id
        return HStack {
            Text(s.name)
                .font(.system(size: 13))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            if let kb = s.keybind {
                Text(kb)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(theme.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(theme.background)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(theme.border, lineWidth: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? theme.surfaceElevated : (isHovered ? theme.rowHover : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? theme.border : Color.clear, lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture { selectedId = (selectedId == s.id) ? nil : s.id }
        .onHover { hovering in
            hoveredId = hovering ? s.id : (hoveredId == s.id ? nil : hoveredId)
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            iconButton(systemImage: "plus", enabled: false, help: "Custom shortcut editor coming in v1.x") {}
            iconButton(systemImage: "minus", enabled: selectedId != nil, help: "Remove selected shortcut") {
                if let id = selectedId { store.delete(id: id); selectedId = nil }
            }
            Spacer()
            Text("Reseed defaults")
                .font(.system(size: 11))
                .foregroundStyle(theme.textSecondary)
            textButton("Reseed") { store.reseed() }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private func iconButton(systemImage: String, enabled: Bool, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 11))
                .foregroundStyle(enabled ? theme.textPrimary : theme.textTertiary)
                .frame(width: 22, height: 22)
                .background(theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(theme.border, lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .help(help)
    }

    private func textButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(theme.textPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(theme.border, lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }
}
