import Foundation

public struct ClassifiedProcess: Equatable, Sendable {
    public let snapshot: ProcessSnapshot
    public let groupId: String
    public let stateTags: [StateTag]

    public init(snapshot: ProcessSnapshot, groupId: String, stateTags: [StateTag]) {
        self.snapshot = snapshot
        self.groupId = groupId
        self.stateTags = stateTags
    }
}

extension ClassifiedProcess {
    /// A friendly display name. Falls back when the raw process name is unhelpful
    /// (e.g. version strings like "2.1.145" that Claude CLI sets as its proctitle).
    public var displayName: String {
        let raw = snapshot.name
        let versionPattern = raw.allSatisfy { $0.isNumber || $0 == "." }
        if versionPattern && !raw.isEmpty {
            if let argv0 = snapshot.argv.first {
                let base = (argv0 as NSString).lastPathComponent
                if !base.isEmpty && !base.allSatisfy({ $0.isNumber || $0 == "." }) {
                    return base
                }
            }
            return groupId.replacingOccurrences(of: "-", with: " ").capitalized
        }
        return raw
    }
}

public enum StateTag: String, Codable, Equatable, Sendable {
    case active
    case idle
    case stale
    case orphan
    case zombie
}
