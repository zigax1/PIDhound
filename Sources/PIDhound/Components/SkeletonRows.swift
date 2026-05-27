import SwiftUI

public struct SkeletonRows: View {
    @Environment(\.theme) private var theme
    public let rowCount: Int
    public let columnWidths: [CGFloat?]

    @State private var phase: CGFloat = 0

    public init(rowCount: Int, columnWidths: [CGFloat?]) {
        self.rowCount = rowCount
        self.columnWidths = columnWidths
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { _ in
                HStack(spacing: 12) {
                    ForEach(Array(columnWidths.enumerated()), id: \.offset) { _, width in
                        skeletonBar(width: width)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    @ViewBuilder
    private func skeletonBar(width: CGFloat?) -> some View {
        let bar = RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(theme.surface)
            .opacity(0.65 + 0.30 * phase)
            .frame(height: 10)
        if let w = width {
            bar.frame(width: w, alignment: .leading)
        } else {
            bar.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
