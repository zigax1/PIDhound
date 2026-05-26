#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${VERSION:-1.0.0}"
APP_NAME="PIDhound"
APP="dist/${APP_NAME}.app"
DMG="dist/PIDhound-${VERSION}.dmg"

if [ ! -d "${APP}" ]; then
    echo "Error: ${APP} not found. Run scripts/build-app-bundle.sh first." >&2
    exit 1
fi

rm -f "${DMG}"

# Create a temporary directory for DMG contents
STAGING=$(mktemp -d)
cp -R "${APP}" "${STAGING}/"
ln -s /Applications "${STAGING}/Applications"

# Create DMG
hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGING}" -ov -format UDZO "${DMG}"

rm -rf "${STAGING}"

echo ""
echo "Done: ${DMG}"
echo "Size: $(du -h "${DMG}" | cut -f1)"
echo "SHA256:"
shasum -a 256 "${DMG}"
