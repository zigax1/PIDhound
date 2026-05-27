import SwiftUI

public struct ThemedToggle: View {
    @Environment(\.theme) private var theme
    public let label: String
    public let helper: String?
    @Binding public var isOn: Bool

    public init(_ label: String, helper: String? = nil, isOn: Binding<Bool>) {
        self.label = label
        self.helper = helper
        self._isOn = isOn
    }

    public var body: some View {
        ThemedRow(label, helper: helper) {
            EmptyView()
        } trailing: {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(theme.accent)
        }
    }
}
