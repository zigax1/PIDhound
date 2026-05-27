import AppKit
import SwiftUI

public struct AboutPane: View {
    @Environment(\.theme) private var theme
    public init() {}

    public var body: some View {
        ThemedSection {
            VStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                Text("PIDhound")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                Text("v1.0 (development)")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.textSecondary)
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
                    .padding(.vertical, 4)
                Text("Sniffs out the AI processes you forgot about.")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.textPrimary)
                    .multilineTextAlignment(.center)
                Link("github.com/zigax1/PIDhound", destination: URL(string: "https://github.com/zigax1/PIDhound")!)
                    .font(.system(size: 12))
                    .foregroundStyle(theme.accent)
                Text("MIT License")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}
