import Foundation
import Observation
import Persistence
import Shortcuts

@Observable
@MainActor
public final class ShortcutsStore {
    private let database: Database
    public private(set) var shortcuts: [Shortcut] = []

    public init(database: Database) throws {
        self.database = database
        try ShortcutRecord.ensureSeeded(database: database)
        self.shortcuts = try ShortcutRecord.loadAll(from: database)
    }

    public func add(_ s: Shortcut) {
        try? ShortcutRecord.save(s, into: database)
        shortcuts = (try? ShortcutRecord.loadAll(from: database)) ?? []
    }

    public func delete(id: UUID) {
        try? ShortcutRecord.delete(id: id, from: database)
        shortcuts = (try? ShortcutRecord.loadAll(from: database)) ?? []
    }

    public func reseed() {
        for s in shortcuts { try? ShortcutRecord.delete(id: s.id, from: database) }
        try? ShortcutRecord.ensureSeeded(database: database)
        shortcuts = (try? ShortcutRecord.loadAll(from: database)) ?? []
    }
}
