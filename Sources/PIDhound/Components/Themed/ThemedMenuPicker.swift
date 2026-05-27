import SwiftUI

public struct ThemedMenuPicker<Value: Hashable>: View {
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
            Menu {
                ForEach(options, id: \.value) { opt in
                    Button(opt.label) { selection = opt.value }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentLabel)
                        .font(.system(size: 12))
                        .foregroundStyle(theme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .fixedSize()
        }
    }

    private var currentLabel: String {
        options.first(where: { $0.value == selection })?.label ?? "—"
    }
}
