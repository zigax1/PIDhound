# Contributing to PIDhound

Thanks for your interest. PIDhound is a small, opinionated tool — see [ROADMAP.md](./ROADMAP.md) for scope.

## Quick start

Requirements: macOS 14+ (Sonoma), Apple Silicon, Swift 5.10+. Either Command Line Tools or full Xcode works for development.

```sh
git clone https://github.com/zigax1/PIDhound.git
cd PIDhound
make build
make test                            # 47+ tests, all should pass
swift run pidhound                   # the menu bar app
swift run pidhound-cli               # the headless CLI
```

If `make test` shows zero tests passed (silent green), you're on CLT-only and the Makefile's Testing.framework workaround is needed — it's already wired, just always use `make test`, never bare `swift test`.


## Most-wanted contributions

- **Classification rules.** If PIDhound doesn't recognize a tool you use, add it to `Sources/Processes/Resources/rules.yaml` and add a fixture-based test. See existing rules for the pattern.
- **Theme variants.** New themes go in `Sources/PIDhound/Theme/Themes.swift`. Each theme must define all 12 color slots from `Theme.swift`.
- **Shortcut presets.** Useful one-click kill profiles go in `Sources/Shortcuts/DefaultShortcuts.swift`.

## Architecture

The project is a SwiftPM workspace with five library targets and two executables:

- `Sensors` — vitals (CPU/RAM/uptime/thermal) via Mach + sysctl
- `Processes` — process enumeration via `sysctl KERN_PROC` + classification engine
- `Grouping` — aggregates classified processes into groups
- `Shortcuts` — match specs + kill runner (SIGTERM/SIGKILL)
- `Persistence` — SQLite via GRDB
- `PIDhoundCore` — orchestrates the sampling pipeline
- `pidhound` (exe) — SwiftUI menu bar app
- `pidhound-cli` (exe) — headless CLI for debugging

The design spec is at `docs/superpowers/specs/2026-05-21-pidhound-design.md`.

## Rules for AI assistants

If you're contributing via an AI coding assistant, please read [CLAUDE.md](./CLAUDE.md) first. Key rules:
- No telemetry, no analytics, no phone-home — ever.
- No backwards-compatibility shims for older macOS or Intel.
- Native macOS conventions (SF Symbols, SwiftUI, `MenuBarExtra`, `SMAppService`).
- No emojis anywhere — code, commits, UI strings.

## Pull requests

- Tests for any classification rule change.
- One logical change per commit. No "refactor + feature + lint" mega-commits.
- Conventional, lowercase, terse commit messages (`feat:`, `fix:`, `chore:`).
- No AI attribution in commits.

## Manual smoke test

1. `make build && swift run pidhound`
2. Verify CPU icon appears in menu bar (top-right) within 5s
3. Click icon — dropdown opens with vitals + groups + actions
4. Click "Open Dashboard" — dashboard window opens with sidebar + tabs
5. Click "Quit PIDhound" — app exits cleanly
6. Verify SQLite at `~/Library/Application Support/PIDhound/cockpit.sqlite` has rows in `vitals_sample` and `process_sample`

## Publishing a release

1. Tag a commit: `git tag v1.0.0 && git push --tags`
2. Wait for the `release.yml` workflow to finish — it produces a draft release with the DMG attached.
3. Edit the draft release on GitHub, click Publish.
4. Copy the DMG SHA256 from the release body.
5. In the separate `homebrew-pidhound` tap repo, edit `Casks/pidhound.rb` (use `docs/homebrew-cask-template.rb` as a starting point), bump the version and paste the SHA256, commit and push to the tap.

## License

MIT — see [LICENSE](./LICENSE).
