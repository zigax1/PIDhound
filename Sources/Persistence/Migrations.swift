import Foundation
import GRDB

public enum Migrations {
    public static func runAll(on database: Database) throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("001_initial") { db in
            try db.execute(sql: """
                CREATE TABLE vitals_sample (
                    ts INTEGER NOT NULL PRIMARY KEY,
                    cpu_pct REAL,
                    p_core_temp_c REAL,
                    ram_used_bytes INTEGER,
                    ram_total_bytes INTEGER,
                    thermal_state TEXT,
                    uptime_seconds REAL,
                    awake_seconds REAL
                );
            """)
            try db.execute(sql: """
                CREATE TABLE process_sample (
                    ts INTEGER NOT NULL,
                    pid INTEGER NOT NULL,
                    ppid INTEGER,
                    name TEXT,
                    group_id TEXT,
                    state_tags TEXT,
                    cpu_pct REAL,
                    rss_bytes INTEGER,
                    PRIMARY KEY (ts, pid)
                );
            """)
            try db.execute(sql: """
                CREATE TABLE kill_event (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    ts INTEGER NOT NULL,
                    shortcut_id TEXT,
                    pid INTEGER NOT NULL,
                    process_name TEXT,
                    group_id TEXT,
                    reason TEXT
                );
            """)
            try db.execute(sql: """
                CREATE TABLE shortcut (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    match_spec TEXT NOT NULL,
                    keybind TEXT,
                    confirm_before_run INTEGER NOT NULL DEFAULT 1,
                    created_at INTEGER NOT NULL
                );
            """)
            try db.execute(sql: """
                CREATE TABLE setting (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                );
            """)
            try db.execute(sql: "CREATE INDEX idx_process_sample_ts_group ON process_sample (ts, group_id);")
            try db.execute(sql: "CREATE INDEX idx_kill_event_ts ON kill_event (ts);")
        }

        try migrator.migrate(database.queue)
    }
}
