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

# SwiftPM's auto-generated Bundle.module accessor is incompatible with .app
# layouts (it expects bundles at the .app root, which codesign rejects as
# unsealed content). Copy rules.yaml directly to Contents/Resources/ so the
# code can find it via Bundle.main.url(forResource:).
RULES_SRC=".build/release/pidhound_Processes.bundle/rules.yaml"
if [ -f "${RULES_SRC}" ]; then
    cp "${RULES_SRC}" "${BUNDLE}/Contents/Resources/rules.yaml"
else
    echo "Error: ${RULES_SRC} not found - SwiftPM resource bundle missing" >&2
    exit 1
fi

# Code signing
# - With a Developer ID in PIDHOUND_SIGN_IDENTITY: full signature + hardened runtime.
# - Without one: ad-hoc sign (-s -). On Sequoia/Tahoe, fully unsigned apps trigger
#   a "damaged" alert with no right-click-Open escape hatch. Ad-hoc signing keeps
#   the standard Gatekeeper prompt where the user can right-click -> Open once.
if [ -n "${PIDHOUND_SIGN_IDENTITY:-}" ]; then
    echo "Signing with identity: ${PIDHOUND_SIGN_IDENTITY}"
    codesign --force --options runtime --sign "${PIDHOUND_SIGN_IDENTITY}" "${BUNDLE}"
else
    echo "Ad-hoc signing (no Developer ID set)"
    codesign --force --deep --sign - "${BUNDLE}"
fi

echo ""
echo "Done: ${BUNDLE}"
echo "To run: open '${BUNDLE}'"
