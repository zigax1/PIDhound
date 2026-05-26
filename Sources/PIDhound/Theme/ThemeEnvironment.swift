import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .modern
}

extension EnvironmentValues {
    public var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    public func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
