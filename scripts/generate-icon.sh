#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ICONSET="resources/AppIcon.iconset"
rm -rf "${ICONSET}"
mkdir -p "${ICONSET}"

# PIDhound icon — pawprint silhouette on dark rounded square.
# Use NSBitmapImageRep directly to avoid Retina 2x scaling from lockFocus.
SWIFT_SCRIPT=$(cat <<'EOF'
import AppKit

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

    // Accent green (matches Modern theme's accent)
    let accent = NSColor(srgbRed: 0.302, green: 0.890, blue: 0.522, alpha: 1)
    accent.setFill()

    let cx = sz * 0.5
    let cy = sz * 0.43

    // ---- Central pad — rounded triangular shape ----
    let padW = sz * 0.34
    let padH = sz * 0.30
    let pad = NSBezierPath()
    pad.move(to: NSPoint(x: cx, y: cy - padH * 0.50))
    pad.curve(to: NSPoint(x: cx - padW * 0.50, y: cy),
              controlPoint1: NSPoint(x: cx - padW * 0.55, y: cy - padH * 0.50),
              controlPoint2: NSPoint(x: cx - padW * 0.55, y: cy - padH * 0.15))
    pad.curve(to: NSPoint(x: cx, y: cy + padH * 0.50),
              controlPoint1: NSPoint(x: cx - padW * 0.45, y: cy + padH * 0.35),
              controlPoint2: NSPoint(x: cx - padW * 0.18, y: cy + padH * 0.50))
    pad.curve(to: NSPoint(x: cx + padW * 0.50, y: cy),
              controlPoint1: NSPoint(x: cx + padW * 0.18, y: cy + padH * 0.50),
              controlPoint2: NSPoint(x: cx + padW * 0.45, y: cy + padH * 0.35))
    pad.curve(to: NSPoint(x: cx, y: cy - padH * 0.50),
              controlPoint1: NSPoint(x: cx + padW * 0.55, y: cy - padH * 0.15),
              controlPoint2: NSPoint(x: cx + padW * 0.55, y: cy - padH * 0.50))
    pad.close()
    pad.fill()

    // ---- 4 toes arranged in an arc above the pad ----
    // Each toe is an oval, slightly taller than wide.
    let toeBigW = sz * 0.13
    let toeBigH = sz * 0.16
    let toeSmallW = sz * 0.11
    let toeSmallH = sz * 0.13

    // Positions: (xOffset from cx, yOffset from cy, w, h)
    let toes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (-sz * 0.22, sz * 0.18, toeSmallW, toeSmallH),  // outer-left  (lower)
        (-sz * 0.09, sz * 0.30, toeBigW,   toeBigH),    // inner-left  (higher)
        ( sz * 0.09, sz * 0.30, toeBigW,   toeBigH),    // inner-right (higher)
        ( sz * 0.22, sz * 0.18, toeSmallW, toeSmallH),  // outer-right (lower)
    ]
    for (dx, dy, w, h) in toes {
        let r = NSRect(x: cx + dx - w * 0.5, y: cy + dy - h * 0.5, width: w, height: h)
        NSBezierPath(ovalIn: r).fill()
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

var rendered: [Int: Data] = [:]
for (size, _) in outputs {
    if rendered[size] != nil { continue }
    rendered[size] = renderIcon(pixelSize: size)
}

let outDir = CommandLine.arguments[1]
for (size, filename) in outputs {
    guard let png = rendered[size] else { continue }
    let path = outDir + "/" + filename
    try? png.write(to: URL(fileURLWithPath: path))
}
EOF
)

TMPDIR_SCRIPT=$(mktemp -d)
echo "${SWIFT_SCRIPT}" > "${TMPDIR_SCRIPT}/gen.swift"
swift "${TMPDIR_SCRIPT}/gen.swift" "${ICONSET}"

echo "Iconset contents:"
ls -la "${ICONSET}"

iconutil -c icns "${ICONSET}" -o resources/AppIcon.icns

echo ""
echo "Done: resources/AppIcon.icns"
ls -lh resources/AppIcon.icns
file resources/AppIcon.icns
