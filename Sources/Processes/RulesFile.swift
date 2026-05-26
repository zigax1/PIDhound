import Foundation
import Yams

public struct RulesFile: Codable, Sendable {
    public let version: Int
    public let groups: [GroupRule]

    public init(version: Int, groups: [GroupRule]) {
        self.version = version
        self.groups = groups
    }
}

public struct GroupRule: Codable, Sendable {
    public let id: String
    public let label: String
    public let order: Int
    public let match: MatchRule
    public let idleThresholdMinutes: Int?
    public let staleThresholdMinutes: Int?
    public let neverOrphan: Bool?

    enum CodingKeys: String, CodingKey {
        case id, label, order, match
        case idleThresholdMinutes = "idle_threshold_minutes"
        case staleThresholdMinutes = "stale_threshold_minutes"
        case neverOrphan = "never_orphan"
    }
}

public struct MatchRule: Codable, Sendable {
    public let processName: [String]?
    public let argvContains: [String]?
    public let ancestorContains: [String]?

    enum CodingKeys: String, CodingKey {
        case processName = "process_name"
        case argvContains = "argv_contains"
        case ancestorContains = "ancestor_contains"
    }
}

extension RulesFile {
    public static func from(yaml: String) throws -> RulesFile {
        let decoder = YAMLDecoder()
        return try decoder.decode(RulesFile.self, from: yaml)
    }

    public static func loadBundled() throws -> RulesFile {
        guard let url = Bundle.module.url(forResource: "rules", withExtension: "yaml") else {
            throw RulesFileError.bundledFileMissing
        }
        let yaml = try String(contentsOf: url, encoding: .utf8)
        return try from(yaml: yaml)
    }
}

public enum RulesFileError: Error {
    case bundledFileMissing
}
