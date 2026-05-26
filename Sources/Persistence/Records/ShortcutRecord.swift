import Foundation
import GRDB
import Shortcuts

public enum ShortcutRecord {
    public static func loadAll(from database: Database) throws -> [Shortcut] {
        try database.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT id, name, match_spec, keybind, confirm_before_run, created_at FROM shortcut ORDER BY created_at ASC")
            return try rows.compactMap { row -> Shortcut? in
                guard let idStr = row["id"] as String?, let id = UUID(uuidString: idStr),
                      let name = row["name"] as String?,
                      let matchJson = row["match_spec"] as String?,
                      let matchData = matchJson.data(using: .utf8) else { return nil }
                let match = try JSONDecoder().decode(MatchSpec.self, from: matchData)
                return Shortcut(
                    id: id,
                    name: name,
                    match: match,
                    keybind: row["keybind"] as String?,
                    confirmBeforeRun: (row["confirm_before_run"] as Int? ?? 1) == 1,
                    createdAt: Date(timeIntervalSince1970: TimeInterval(row["created_at"] as Int64? ?? 0))
                )
            }
        }
    }

    public static func save(_ s: Shortcut, into database: Database) throws {
        let matchData = try JSONEncoder().encode(s.match)
        let matchJson = String(data: matchData, encoding: .utf8) ?? "{}"
        try database.write { db in
            try db.execute(sql: """
                INSERT OR REPLACE INTO shortcut (id, name, match_spec, keybind, confirm_before_run, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, arguments: [
                s.id.uuidString, s.name, matchJson, s.keybind,
                s.confirmBeforeRun ? 1 : 0, Int64(s.createdAt.timeIntervalSince1970)
            ])
        }
    }

    public static func delete(id: UUID, from database: Database) throws {
        try database.write { db in
            try db.execute(sql: "DELETE FROM shortcut WHERE id = ?", arguments: [id.uuidString])
        }
    }

    public static func saveKillEvent(pid: Int32, processName: String, groupId: String?, reason: String, shortcutId: String? = nil, into database: Database) throws {
        try database.write { db in
            try db.execute(sql: """
                INSERT INTO kill_event (ts, shortcut_id, pid, process_name, group_id, reason)
                VALUES (?, ?, ?, ?, ?, ?)
            """, arguments: [Int64(Date().timeIntervalSince1970), shortcutId, pid, processName, groupId, reason])
        }
    }

    public static func ensureSeeded(database: Database) throws {
        let existing = try loadAll(from: database)
        guard existing.isEmpty else { return }
        for s in DefaultShortcuts.seeded() {
            try save(s, into: database)
        }
    }
}
