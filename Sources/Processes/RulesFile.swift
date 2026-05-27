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
        // SwiftPM's auto-generated Bundle.module is unusable in .app builds:
        // its first lookup path puts the resource bundle at the .app root,
        // which codesign rejects as unsealed content. Resolve manually for
        // production paths and only fall back to Bundle.module under the
        // SwiftPM test runner, where Bundle.main points outside our build tree.
        let candidates: [URL] = [
            // .app: Contents/Resources/rules.yaml
            Bundle.main.url(forResource: "rules", withExtension: "yaml"),
            // SwiftPM CLI (swift run): bundle sits next to the executable.
            Bundle.main.bundleURL.appendingPathComponent("pidhound_Processes.bundle/rules.yaml"),
        ].compactMap { $0 }

        for url in candidates where FileManager.default.fileExists(atPath: url.path) {
            let yaml = try String(contentsOf: url, encoding: .utf8)
            return try from(yaml: yaml)
        }

        if isSwiftPMTestRunner, let url = Bundle.module.url(forResource: "rules", withExtension: "yaml") {
            let yaml = try String(contentsOf: url, encoding: .utf8)
            return try from(yaml: yaml)
        }
        throw RulesFileError.bundledFileMissing
    }

    private static var isSwiftPMTestRunner: Bool {
        guard let name = Bundle.main.executableURL?.lastPathComponent else { return false }
        return name == "swiftpm-testing-helper" || name.hasPrefix("xctest")
    }
}

public enum RulesFileError: Error {
    case bundledFileMissing
}
