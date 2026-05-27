import SwiftUI

public struct ThemedSidebarItem<Value: Hashable>: Identifiable {
    public let id: Value
    public let label: String
    public let systemImage: String

    public init(id: Value, label: String, systemImage: String) {
        self.id = id
        self.label = label
        self.systemImage = systemImage
    }
}

public struct ThemedSidebar<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    public let items: [ThemedSidebarItem<Value>]
    @Binding public var selection: Value
    @State private var hoveredID: Value?

    public init(items: [ThemedSidebarItem<Value>], selection: Binding<Value>) {
        self.items = items
        self._selection = selection
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(items) { item in
                row(item)
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(width: 180)
        .background(theme.surface)
    }

    private func row(_ item: ThemedSidebarItem<Value>) -> some View {
        let isSelected = selection == item.id
        let isHovered = hoveredID == item.id
        return Button(action: { selection = item.id }) {
            HStack(spacing: 8) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(item.label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                Spacer()
            }
            .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? theme.surfaceElevated : (isHovered ? theme.rowHover : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? theme.border : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredID = hovering ? item.id : (hoveredID == item.id ? nil : hoveredID)
        }
    }
}
