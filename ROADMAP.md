# PIDhound — Roadmap

> Stable file. Any AI assistant working on this repo must read this before suggesting features. If a feature isn't here, propose adding it to the roadmap first — don't just build it.

## Implementation phases (v1.0)

v1.0 is built in 4 sequential implementation plans. Each plan finishes in a runnable state — you can pause, test, iterate before moving on.

| Phase | Plan | Outcome | Status | File |
|---|---|---|---|---|
| 1 | Core Data Pipeline | Headless CLI showing live vitals + classified processes + SQLite persistence. No UI. | Complete | `docs/superpowers/plans/2026-05-21-plan-1-core-data-pipeline.md` |
| 2 | Menu Bar App + Theme System | Real menu-bar app with live vitals dropdown. Theme system, 4 themes switchable. Minimal main window placeholder. | Complete | `docs/superpowers/plans/2026-05-25-plan-2-menu-bar-app.md` |
| 3 | Full Dashboard + Shortcuts + Settings | Complete dashboard window, shortcuts system, settings panes, onboarding, launch-at-login. | Complete | `docs/superpowers/plans/2026-05-25-plan-3-dashboard-shortcuts-settings.md` |
| 4 | Polish + Release Prep | Error handling refinement, integration smoke tests, performance, DMG build script. | Complete | `docs/superpowers/plans/2026-05-25-plan-4-polish-release.md` |

Plans 2-4 will be written after Plan 1 implementation completes, so they can incorporate any lessons learned.

## v1.0 — Simple Mode MVP

The shippable core. Lightweight, plug-and-play, no setup.

### Sensors & vitals (no-sudo)
- [x] IOReport sampler for P-core / E-core utilization and per-cluster power
- [ ] P-core temperature (no-sudo approximation) — deferred to v1.x (requires IOReport binding)
- [x] RAM used / total
- [x] Thermal pressure (nominal / moderate / heavy / critical)
- [x] System uptime (boot time + last wake)

### Process layer
- [x] `libproc` C bridge: list all PIDs, fetch name/ppid/argv/cwd/RSS/CPU%
- [x] Classification engine driven by `Rules.bundle/rules.yaml`
- [x] Classifications for: Claude Code sessions, MCP servers, AI assistants (Cursor, Codex, Aider, Continue), Playwright browsers, Test runners (Cypress, Vitest, Jest, pytest), Dev servers (Vite, Next, Django, Rails, FastAPI), Docker containers, Listening ports, Other (collapsible)
- [x] State tags: `active`, `idle Xm`, `stale`, `orphan`, `zombie`
- [x] Idle/stale detection via CPU activity tracking + ancestor liveness

### Persistence
- [x] SQLite via GRDB.swift
- [x] Schema migrations
- [ ] Raw 5 s samples; 1 m / 1 h rollups; 30 d / 1 yr retention — deferred to v1.x (DB rollups not yet implemented)

### UI — menu bar
- [x] MenuBarExtra with vitals widget (icon + temp + stale count formats)
- [x] Dropdown panel: stale recap, vitals, group counts, shortcut chips, Open Dashboard / Settings / Quit

### UI — dashboard
- [x] Vitals sidebar (CPU, temp, RAM, thermal, uptime, Power User upsell)
- [x] Quick Recap card with "Kill all stale" action
- [x] Group list with collapsible cards and per-row state tags
- [x] Other group (collapsed by default)
- [x] Shortcut chip bar
- [x] Ports tab with kill-by-port
- [x] Minimal History tab: 24 h dual-axis sparkline + kill event log

### Shortcuts
- [x] MatchSpec model (group+tags, name/argv regex, port, ancestor, composed)
- [x] ShortcutRunner: SIGTERM, 3 s wait, SIGKILL fallback
- [x] Pre-seeded shortcuts: kill orphan MCPs, kill stale Claude, kill all Playwright, free port 5173, kill zombie browsers
- [ ] Custom shortcut editor with keybinds and confirmation toggle
- [ ] Import/export shortcuts as JSON

### Themes
- [x] Theme value type + ThemeManager
- [x] Modern (default), Terminal Green, Cyberdeck Amber, Neon Cyber

### Settings
- [x] General pane (launch at login, polling rate, window close behavior)
- [x] Appearance pane (theme, menu bar format, density)
- [x] Shortcuts pane (list + editor)
- [x] Power User Mode pane (visible but disabled; reveals v2 surface only when toggle is on)
- [x] About pane (version, GitHub link, license, credits)

### Lifecycle & onboarding
- [x] `LSUIElement = true`, menu-bar-only by default
- [x] Launch-at-login via SMAppService (opt-in)
- [x] 3-step onboarding sheet (no API keys, no sudo)

### Build & release
- [x] CI: GitHub Actions PR build + test on macos-14
- [x] Tagged release: build, DMG package, draft GitHub Release
- [x] Homebrew cask template in `docs/homebrew-cask-template.rb` (actual tap repo is user-created separately)
- [x] Decide code signing (decided: ship unsigned for v1.0, document right-click → Open in README)

### Docs
- [x] README with screenshots, install instructions, vs Activity Monitor comparison (screenshots are placeholders; user can replace before public release)
- [x] CONTRIBUTING.md
- [x] CLAUDE.md (this file's sibling)
- [x] License: MIT

### v1.0 — release-ready

All implementation plans (1-4) complete. App can be built into a draggable DMG via:
```sh
./scripts/build-app-bundle.sh
./scripts/build-dmg.sh
```

Outstanding before public release (user decisions):
- Optional: real screenshots/GIF for README (currently placeholders)
- Optional: Apple Developer Program signing + notarization
- Required: create the public `pidhound` repo on GitHub and the `homebrew-pidhound` tap repo (separate)

## v1.x — Simple Mode polish

Small wins after the v1.0 release.

- [ ] Better classification rules from real-world feedback (PRs welcome — `rules.yaml`)
- [ ] More pre-seeded shortcuts based on community asks
- [ ] User-override `~/Library/Application Support/PIDhound/rules.user.yaml`
- [ ] Keyboard-driven dashboard navigation (j/k row movement, x to kill, etc.)
- [ ] Window state persistence
- [ ] Better app icon (hire/commission)
- [ ] Browser tabs deep dive (Chrome's 87 tabs view) — bonus category

## v2.0 — Power User Mode

The AI-and-thermals upgrade. Gated behind a single toggle. Off by default.

### AI features
- [ ] `LLMProvider` protocol with `OpenRouterProvider` and `AnthropicProvider` implementations
- [ ] On-demand AI chat tab: "What was running when CPU spiked at 14:30?"
- [ ] Daily summary digest (Claude Haiku 4.5 by default, configurable)
- [ ] Model picker (Haiku 4.5 / Sonnet 4.6 / Opus 4.7 / + OpenRouter models)
- [ ] Provider key entry + Test button
- [ ] Token cost tracking

### Full thermals (powermetrics)
- [ ] Sudoers wizard via osascript with admin prompt
- [ ] Fan RPM
- [ ] Per-cluster temperatures
- [ ] Per-process energy impact (Apple Silicon-only metric)
- [ ] Disable wizard (removes sudoers entry)

### Deeper history
- [ ] Multi-day analytics view (7d / 30d charts)
- [ ] "Worst offenders" leaderboards by week
- [ ] Cleanup-impact stats: "Killing stale items saved you 4.3 hours of fan time this month"

## v3.0 — Proactive

The watchful-AI release.

- [ ] Anomaly detection: sustained high temp / runaway process / sudden RAM growth
- [ ] Toast notifications via `UNUserNotificationCenter` with kill action buttons
- [ ] Optional local model support via Ollama (Llama 3.3 or successors)
- [ ] User-tunable alert thresholds
- [ ] "Recovery mode": when overheating detected, surface the suggested kill set

## v4.0 — Broader workloads (expansion)

When the AI/dev niche is covered, expand to adjacent engineering audiences.

- [ ] Render workloads: Blender, Houdini, Cinema 4D, Maya
- [ ] ML training: PyTorch, TensorFlow, JAX long-running jobs
- [ ] Video encoders: FFmpeg, DaVinci Resolve background renders
- [ ] Photogrammetry: WebODM, Reality Capture, Metashape
- [ ] GPU memory + utilization in vitals (Metal Performance Shaders telemetry)
- [ ] New theme variants tuned for these workflows

## Out of scope (forever)

- iCloud sync / multi-Mac dashboards
- Window management / window snapping features
- Cross-platform support (macOS only is by design)
- Replacing Activity Monitor's Disk I/O, Network, or Energy tabs
- Per-thread inspection
- Telemetry, analytics, or any phone-home
