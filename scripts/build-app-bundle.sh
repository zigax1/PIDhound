#!/usr/bin/env bash
set -euo pipefail

# Build a proper PIDhound.app bundle from the SwiftPM executable.
# Output: dist/PIDhound.app

cd "$(dirname "$0")/.."

VERSION="${VERSION:-1.0.0}"
BUILD="${BUILD:-$(date +%s)}"
APP_NAME="PIDhound"
BUNDLE="dist/${APP_NAME}.app"
EXE="pidhound"

echo "Building release executable..."
swift build -c release

EXE_PATH=".build/release/${EXE}"
if [ ! -f "${EXE_PATH}" ]; then
    echo "Error: ${EXE_PATH} not found after build" >&2
    exit 1
fi

echo "Assembling app bundle at ${BUNDLE}..."
rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}/Contents/MacOS"
mkdir -p "${BUNDLE}/Contents/Resources"

cp "${EXE_PATH}" "${BUNDLE}/Contents/MacOS/${EXE}"
chmod +x "${BUNDLE}/Contents/MacOS/${EXE}"

# Generate Info.plist from template with version substitution
sed -e "s/__VERSION__/${VERSION}/g" -e "s/__BUILD__/${BUILD}/g" \
    resources/Info.plist.template > "${BUNDLE}/Contents/Info.plist"

# Copy AppIcon if it exists
if [ -f "resources/AppIcon.icns" ]; then
    cp "resources/AppIcon.icns" "${BUNDLE}/Contents/Resources/AppIcon.icns"
fi

# Copy resource bundles (rules.yaml and others SwiftPM resource accessors expect)
for bundle_src in .build/release/*.bundle; do
    if [ -d "${bundle_src}" ]; then
        cp -r "${bundle_src}" "${BUNDLE}/Contents/Resources/"
    fi
done

# Code signing (best-effort, only if a Developer ID is set in environment)
if [ -n "${PIDHOUND_SIGN_IDENTITY:-}" ]; then
    echo "Signing with identity: ${PIDHOUND_SIGN_IDENTITY}"
    codesign --force --options runtime --sign "${PIDHOUND_SIGN_IDENTITY}" "${BUNDLE}"
else
    echo "Skipping code signing (set PIDHOUND_SIGN_IDENTITY to enable)"
fi

echo ""
echo "Done: ${BUNDLE}"
echo "To run: open '${BUNDLE}'"
