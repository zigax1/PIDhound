import Foundation
import GRDB

public final class Database: @unchecked Sendable {
    let queue: DatabaseQueue

    init(queue: DatabaseQueue) {
        self.queue = queue
    }

    public static func inMemory() throws -> Database {
        Database(queue: try DatabaseQueue())
    }

    public static func atPath(_ path: String) throws -> Database {
        Database(queue: try DatabaseQueue(path: path))
    }

    public func read<T>(_ block: (GRDB.Database) throws -> T) throws -> T {
        try queue.read(block)
    }

    public func write<T>(_ block: (GRDB.Database) throws -> T) throws -> T {
        try queue.write(block)
    }
}

extension GRDB.Database {
    public func tableNames() throws -> [String] {
        let rows = try Row.fetchAll(self, sql: "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'grdb_%'")
        return rows.map { $0["name"] as String? ?? "" }
    }
}
