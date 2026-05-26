# Build scripts

- **`build-app-bundle.sh`** — Wraps the SwiftPM release exe as `dist/PIDhound.app`. Run from repo root: `./scripts/build-app-bundle.sh`. Honors env vars `VERSION` (default `1.0.0`), `BUILD` (default unix timestamp), `PIDHOUND_SIGN_IDENTITY` (Developer ID for codesign — optional).
- **`generate-icon.sh`** — Generates `resources/AppIcon.icns` from `resources/AppIcon.iconset/`. Requires `iconutil` (ships with CLT).
- **`build-dmg.sh`** — Packages `dist/PIDhound.app` as `dist/PIDhound-${VERSION}.dmg`. Uses `hdiutil` (built-in).

Typical release flow: `./scripts/generate-icon.sh && ./scripts/build-app-bundle.sh && ./scripts/build-dmg.sh`

## Refreshing the macOS icon cache

macOS caches app icons aggressively. After rebuilding the bundle with a new icon, you may still see the old icon in the Dock or Finder. To force a refresh:

```sh
# Re-register the bundle with LaunchServices
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -v -f "dist/PIDhound.app"

# Restart Dock and Finder
killall Dock
killall Finder
```

If the icon still doesn't refresh, move the .app to Trash, empty Trash, rebuild, and copy fresh.
