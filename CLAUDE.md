# Rules for AI Assistants Working on PIDhound

Read this file before suggesting any changes to this repo. These rules are stable and override default assistant behavior where they conflict.

## 1. Always read these first

Before touching code in any task, read:
- `ROADMAP.md` — what's planned and in which phase
- `docs/superpowers/specs/2026-05-21-pidhound-design.md` — the canonical design spec
- This file (`CLAUDE.md`)

If a requested change isn't covered by the spec or roadmap, propose adding it to the roadmap first. Do not silently expand scope.

## 2. Scope discipline

This project ships in phases. Respect the phase boundaries:

- **v1.0 (Simple Mode MVP)** — no AI, no API keys, no sudo, no setup. Plug-and-play.
- **v2.0 (Power User Mode)** — AI features, powermetrics, deeper history. Gated behind a single Settings toggle, off by default.
- **v3.0 (Proactive)** — anomaly detection, notifications.

Do not pull v2 or v3 work into v1 without an explicit user decision and a roadmap update.

## 3. The Simple Mode / Power User Mode split

The product has two user-facing modes controlled by one toggle in Settings → Power User Mode (default off).

- Anything that requires an API key, sudo, external setup, or potentially-confusing depth → must be gated behind Power User Mode.
- Simple Mode UI must look complete on its own. The Power User Mode upsell should be discoverable but not nagging.
- Power User Mode pane in v1 ships as mostly-disabled UI — the toggle exists, but most controls are stubs until v2.

## 4. Stack constraints (do not deviate without user approval)

- **Language:** Swift 5.10+/6 only.
- **UI:** SwiftUI on macOS 14+ (Sonoma). No AppKit fallbacks unless a SwiftUI primitive is genuinely unavailable.
- **Platform:** Apple Silicon only. Do not write Intel/Rosetta code paths.
- **Storage:** SQLite via `GRDB.swift`. Do not introduce SwiftData or Core Data.
- **Sensors (default mode):** Direct IOReport bindings, in-repo wrapper. Do not pull in third-party crates/packages for sensors.
- **Sensors (Power User Mode):** Shell out to `powermetrics` via NOPASSWD sudoers entry installed by the wizard. Nothing else.
- **Process listing:** `libproc` C-bridge. Do not parse `ps` output.
- **HTTP (v2 AI):** `URLSession`. Do not add Swift LLM SDKs.
- **Logging:** `os.Logger` (unified logging). Do not add SwiftLog or other logging frameworks.
- **Testing:** Swift Testing framework (`import Testing`). Do not use XCTest for new tests.

## 5. Native macOS conventions

- Use SF Symbols where icons make sense.
- Use system notifications (`UNUserNotificationCenter`) for any future toast UI.
- Use `MenuBarExtra` for the menu bar widget.
- Use `WindowGroup` and `Settings` scenes for windows.
- Use `SMAppService` for launch-at-login.
- Use system keyboard shortcuts (`keyboardShortcut(...)` modifier).

## 6. Theme discipline

- All UI colors must come through the `Theme` value type and `@Environment(\.theme)`.
- Do not hard-code colors. If you find yourself reaching for a `Color(red: ..., green: ..., blue: ...)` literal in a view, you are doing something wrong — add the slot to `Theme` instead.
- Themes ship as Swift structs in `UI/Theme/Themes.swift`. Adding a theme is a code change, not a runtime change, in v1.

## 7. No emojis

No emojis in code, comments, commit messages, PR descriptions, UI strings, or documentation. This is a user preference and applies project-wide.

## 8. No telemetry, no analytics, no phone-home

Ever. Privacy is a feature.

## 9. No backwards-compatibility code

This is a new project. Do not write fallbacks for older macOS versions, Intel chips, or unreleased Swift features. Do not write feature flags for things that haven't shipped. Do not add deprecation shims.

## 10. Verification before completion

Before claiming a task is done:
- Build the app (`swift build` or Xcode build).
- Actually run it and exercise the changed feature.
- Type checking and unit tests verify correctness, not feature behavior. If the change is UI, see it in the UI.
- Only after observed behavior matches expectations: claim done.

If you cannot verify (e.g., the UI can't be reached in the current environment), say so explicitly. Do not claim success on the basis of compilation alone.

## 11. Commits

- Conventional, terse, lowercase, no emojis.
- Examples: `feat: add quick recap card`, `fix: classifier handles missing argv`, `chore: bump GRDB to 6.30`.
- One logical change per commit. Don't bundle "refactor + new feature + lint" into one commit.

## 12. Comments

- Default to writing no comments.
- Only add a comment when the *why* is non-obvious (a workaround, an Apple Silicon quirk, a Foundation gotcha).
- Never explain *what* the code does. Names should do that.
- Never reference current tasks, PRs, or recent fixes in comments — that's what git history is for.

## 13. Adding categories to the classifier

When a real-world process shape shows up that the classifier misses:
1. Add a test fixture in `Tests/Fixtures/` with the input shape and expected classification.
2. Update `Rules.bundle/rules.yaml` with the new rule.
3. Bump the `version:` field in `rules.yaml` if rules are not backward-compatible.
4. Run the classifier tests.

Do not hard-code classifications in Swift code. Everything goes through the YAML.

## 14. When in doubt

Ask the user. This is a personal/OSS project — there's no harm in confirming an ambiguous design choice. Cheaper than rebuilding.
