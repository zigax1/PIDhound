#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

SVG="resources/AppIcon.svg"
ICONSET="resources/AppIcon.iconset"
ICNS="resources/AppIcon.icns"

if [ ! -f "${SVG}" ]; then
    echo "Error: ${SVG} not found" >&2
    exit 1
fi

rm -rf "${ICONSET}"
mkdir -p "${ICONSET}"

TMPDIR_SCRIPT=$(mktemp -d)
trap 'rm -rf "${TMPDIR_SCRIPT}"' EXIT

qlmanage -t -s 1024 -o "${TMPDIR_SCRIPT}" "${SVG}" >/dev/null
MASTER="${TMPDIR_SCRIPT}/AppIcon.svg.png"
if [ ! -f "${MASTER}" ]; then
    echo "Error: qlmanage failed to render ${SVG}" >&2
    exit 1
fi

cp "${MASTER}" "${ICONSET}/icon_512x512@2x.png"

for spec in \
    "512:icon_512x512.png" \
    "512:icon_256x256@2x.png" \
    "256:icon_256x256.png" \
    "256:icon_128x128@2x.png" \
    "128:icon_128x128.png" \
    "64:icon_32x32@2x.png" \
    "32:icon_32x32.png" \
    "32:icon_16x16@2x.png" \
    "16:icon_16x16.png"
do
    size="${spec%%:*}"
    name="${spec##*:}"
    sips -z "${size}" "${size}" "${MASTER}" --out "${ICONSET}/${name}" >/dev/null
done

iconutil -c icns "${ICONSET}" -o "${ICNS}"

echo "Done: ${ICNS}"
ls -lh "${ICNS}"
