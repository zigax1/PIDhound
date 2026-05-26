import Foundation
import GRDB
import Sensors

public enum VitalsSampleRecord {
    public static func insert(snapshot: VitalsSnapshot, into database: Database) throws {
        try database.write { db in
            try db.execute(sql: """
                INSERT OR REPLACE INTO vitals_sample
                (ts, cpu_pct, p_core_temp_c, ram_used_bytes, ram_total_bytes, thermal_state, uptime_seconds, awake_seconds)
                VALUES (?, ?, NULL, ?, ?, ?, ?, ?)
            """, arguments: [
                Int(snapshot.timestamp.timeIntervalSince1970),
                snapshot.cpuPercent,
                Int64(snapshot.ramUsedBytes),
                Int64(snapshot.ramTotalBytes),
                snapshot.thermalState.rawValue,
                snapshot.uptimeSeconds,
                snapshot.awakeSeconds,
            ])
        }
    }
}
