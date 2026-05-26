import Foundation

public struct ProcessSnapshot: Codable, Equatable, Hashable, Sendable {
    public let pid: Int32
    public let ppid: Int32
    public let name: String
    public let executablePath: String
    public let argv: [String]
    public let cwd: String?
    public let cpuPercent: Double
    public let residentSizeBytes: UInt64
    public let startTime: Date

    public init(
        pid: Int32, ppid: Int32, name: String, executablePath: String,
        argv: [String], cwd: String?, cpuPercent: Double,
        residentSizeBytes: UInt64, startTime: Date
    ) {
        self.pid = pid; self.ppid = ppid; self.name = name
        self.executablePath = executablePath; self.argv = argv; self.cwd = cwd
        self.cpuPercent = cpuPercent; self.residentSizeBytes = residentSizeBytes
        self.startTime = startTime
    }
}
