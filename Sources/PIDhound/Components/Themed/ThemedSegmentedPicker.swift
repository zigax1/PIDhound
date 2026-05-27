import SwiftUI

public struct ThemedSegmentedPicker<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    public let label: String
    public let helper: String?
    public let options: [(value: Value, label: String)]
    @Binding public var selection: Value

    public init(
        _ label: String,
        helper: String? = nil,
        selection: Binding<Value>,
        options: [(Value, String)]
    ) {
        self.label = label
        self.helper = helper
        self._selection = selection
        self.options = options.map { (value: $0.0, label: $0.1) }
    }

    public var body: some View {
        ThemedRow(label, helper: helper) {
            EmptyView()
        } trailing: {
            HStack(spacing: 2) {
                ForEach(options, id: \.value) { opt in
                    segment(opt)
                }
            }
            .padding(2)
            .background(theme.background)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private func segment(_ opt: (value: Value, label: String)) -> some View {
        let isSelected = selection == opt.value
        return Button(action: { selection = opt.value }) {
            Text(opt.label)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? theme.surfaceElevated : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? theme.border : Color.clear, lineWidth: 0.5)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
