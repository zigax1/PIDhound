import Foundation

public enum SupportDirectory {
    public static func resolveAndMigrate() -> String {
        let home = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
        let dir = "\(home)/Library/Application Support/PIDhound"
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }
}
