import Foundation
import GRDB
import Processes

public enum ProcessSampleRecord {
    public static func insert(classified: [ClassifiedProcess], timestamp: Date, into database: Database) throws {
        let ts = Int(timestamp.timeIntervalSince1970)
        try database.write { db in
            for c in classified {
                let tags = c.stateTags.map { $0.rawValue }.joined(separator: ",")
                try db.execute(sql: """
                    INSERT OR REPLACE INTO process_sample
                    (ts, pid, ppid, name, group_id, state_tags, cpu_pct, rss_bytes)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, arguments: [
                    ts, c.snapshot.pid, c.snapshot.ppid, c.snapshot.name,
                    c.groupId, tags, c.snapshot.cpuPercent, Int64(c.snapshot.residentSizeBytes),
                ])
            }
        }
    }
}
