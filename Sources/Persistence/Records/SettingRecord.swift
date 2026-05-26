import Foundation
import GRDB

public enum SettingRecord {
    public static func get(_ key: String, from database: Database) throws -> String? {
        try database.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = ?", arguments: [key])
        }
    }

    public static func set(_ key: String, _ value: String, into database: Database) throws {
        try database.write { db in
            try db.execute(sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)", arguments: [key, value])
        }
    }

    public static func delete(_ key: String, from database: Database) throws {
        try database.write { db in
            try db.execute(sql: "DELETE FROM setting WHERE key = ?", arguments: [key])
        }
    }
}
