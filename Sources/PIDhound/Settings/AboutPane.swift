import AppKit
import SwiftUI

public struct AboutPane: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 72, height: 72)
            Text("PIDhound").font(.title2).fontWeight(.semibold)
            Text("v1.0 (development)").font(.caption).foregroundStyle(.secondary)
            Divider()
            Text("Sniffs out the AI processes you forgot about.").font(.body)
            Link("github.com/zigax1/PIDhound", destination: URL(string: "https://github.com/zigax1/PIDhound")!)
                .font(.caption)
            Spacer()
            Text("MIT License").font(.caption).foregroundStyle(.secondary)
        }
        .padding(24)
    }
}
