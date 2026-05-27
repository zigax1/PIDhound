#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ICONSET="resources/AppIcon.iconset"
rm -rf "${ICONSET}"
mkdir -p "${ICONSET}"

# Generate using AppKit drawing — cockpit-gauge icon.
# iconutil accepts only specific filenames in an iconset.
# Uses NSBitmapImageRep directly to avoid Retina 2x scaling from lockFocus.
TMPDIR_SCRIPT=$(mktemp -d)
cat > "${TMPDIR_SCRIPT}/gen.swift" <<'EOF'
import AppKit

// (pixel size, filename) pairs for a complete iconset
let outputs: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

func renderIcon(pixelSize size: Int) -> Data? {
    let sz = CGFloat(size)

    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return nil }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let rect = NSRect(x: 0, y: 0, width: sz, height: sz)

    // Background: deep near-black rounded square
    let bg = NSBezierPath(roundedRect: rect, xRadius: sz * 0.22, yRadius: sz * 0.22)
    NSColor(srgbRed: 0.05, green: 0.05, blue: 0.06, alpha: 1).setFill()
    bg.fill()

    // Subtle border
    NSColor(srgbRed: 0.20, green: 0.22, blue: 0.26, alpha: 1).setStroke()
    bg.lineWidth = max(1, sz / 256.0 * 2)
    bg.stroke()

    // Outer dial ring (open arc)
    let dialCenter = NSPoint(x: sz / 2, y: sz / 2)
    let dialRadius = sz * 0.32
    let arcPath = NSBezierPath()
    arcPath.appendArc(withCenter: dialCenter, radius: dialRadius,
                      startAngle: 210, endAngle: -30, clockwise: true)
    NSColor(srgbRed: 0.20, green: 0.55, blue: 0.32, alpha: 0.5).setStroke()
    arcPath.lineWidth = max(2.5, sz / 52.0)
    arcPath.lineCapStyle = .round
    arcPath.stroke()

    // Inner active arc — bright green (~60% sweep)
    let activeArc = NSBezierPath()
    activeArc.appendArc(withCenter: dialCenter, radius: dialRadius,
                        startAngle: 210, endAngle: 65, clockwise: true)
    NSColor(srgbRed: 0.286, green: 0.871, blue: 0.502, alpha: 1).setStroke()
    activeArc.lineWidth = max(2.5, sz / 52.0)
    activeArc.lineCapStyle = .round
    activeArc.stroke()

    // Center dot
    let dotRadius = sz * 0.085
    let dot = NSBezierPath(ovalIn: NSRect(
        x: dialCenter.x - dotRadius,
        y: dialCenter.y - dotRadius,
        width: dotRadius * 2,
        height: dotRadius * 2
    ))
    NSColor(srgbRed: 0.286, green: 0.871, blue: 0.502, alpha: 1).setFill()
    dot.fill()

    // Needle pointing to ~1 o'clock
    let needleEnd = NSPoint(
        x: dialCenter.x + cos(45 * .pi / 180) * dialRadius * 0.85,
        y: dialCenter.y + sin(45 * .pi / 180) * dialRadius * 0.85
    )
    let needle = NSBezierPath()
    needle.move(to: dialCenter)
    needle.line(to: needleEnd)
    NSColor(srgbRed: 0.929, green: 0.929, blue: 0.933, alpha: 0.9).setStroke()
    needle.lineWidth = max(3, sz / 48.0)
    needle.lineCapStyle = .round
    needle.stroke()

    NSGraphicsContext.restoreGraphicsState()

    return rep.representation(using: .png, properties: [:])
}

// Render once per unique size, save to all filenames sharing that size
var rendered: [Int: Data] = [:]
for (size, _) in outputs {
    if rendered[size] != nil { continue }
    rendered[size] = renderIcon(pixelSize: size)
}

// Write each output (some sizes get written to multiple filenames)
let outDir = CommandLine.arguments[1]
for (size, filename) in outputs {
    guard let png = rendered[size] else { continue }
    let path = outDir + "/" + filename
    try? png.write(to: URL(fileURLWithPath: path))
}
EOF

swift "${TMPDIR_SCRIPT}/gen.swift" "${ICONSET}"

echo "Iconset contents:"
ls -la "${ICONSET}"

iconutil -c icns "${ICONSET}" -o resources/AppIcon.icns

echo ""
echo "Done: resources/AppIcon.icns"
ls -lh resources/AppIcon.icns
file resources/AppIcon.icns
