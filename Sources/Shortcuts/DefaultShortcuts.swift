import Foundation
import Processes

public enum DefaultShortcuts {
    public static func seeded() -> [Shortcut] {
        [
            Shortcut(name: "Kill orphan MCPs",
                     match: .group(id: "mcp-servers", tagsAny: [.orphan]),
                     keybind: "cmd+1", confirmBeforeRun: true),
            Shortcut(name: "Kill stale Claude sessions",
                     match: .group(id: "claude-code-sessions", tagsAny: [.stale]),
                     keybind: "cmd+2", confirmBeforeRun: true),
            Shortcut(name: "Kill all Playwright",
                     match: .group(id: "playwright-browsers", tagsAny: []),
                     keybind: "cmd+3", confirmBeforeRun: true),
            Shortcut(name: "Free port 5173",
                     match: .port(5173),
                     keybind: "cmd+4", confirmBeforeRun: false),
            Shortcut(name: "Kill zombie browsers",
                     match: .group(id: "playwright-browsers", tagsAny: [.zombie]),
                     keybind: "cmd+5", confirmBeforeRun: false),
        ]
    }
}
