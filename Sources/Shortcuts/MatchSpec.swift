import Foundation
import Processes

public indirect enum MatchSpec: Codable, Equatable, Sendable {
    case group(id: String, tagsAny: [StateTag])    // matches processes in group, optionally filtered by ANY of the tags (empty = all)
    case namePattern(String)                         // simple substring match against process name OR argv
    case port(Int)                                   // matches process whose argv contains :PORT (heuristic)
    case ancestorName(String)                        // matches if the process name has an ancestor (parent chain) with this name — v1: limited to direct parent name check
    case composedOr([MatchSpec])                     // matches if any sub-spec matches
}

public struct Shortcut: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var match: MatchSpec
    public var keybind: String?            // e.g. "cmd+1"
    public var confirmBeforeRun: Bool
    public let createdAt: Date

    public init(id: UUID = UUID(), name: String, match: MatchSpec, keybind: String? = nil, confirmBeforeRun: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.match = match
        self.keybind = keybind
        self.confirmBeforeRun = confirmBeforeRun
        self.createdAt = createdAt
    }
}
