import Foundation

public enum ThermalState: String, Codable, Comparable, Sendable, CaseIterable {
    case nominal
    case moderate
    case heavy
    case critical

    public static func < (lhs: ThermalState, rhs: ThermalState) -> Bool {
        let order: [ThermalState] = [.nominal, .moderate, .heavy, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

public struct VitalsSnapshot: Codable, Equatable, Sendable {
    public let timestamp: Date
    public let cpuPercent: Double
    public let ramUsedBytes: UInt64
    public let ramTotalBytes: UInt64
    public let thermalState: ThermalState
    public let uptimeSeconds: TimeInterval
    public let awakeSeconds: TimeInterval

    public init(
        timestamp: Date,
        cpuPercent: Double,
        ramUsedBytes: UInt64,
        ramTotalBytes: UInt64,
        thermalState: ThermalState,
        uptimeSeconds: TimeInterval,
        awakeSeconds: TimeInterval
    ) {
        self.timestamp = timestamp
        self.cpuPercent = cpuPercent
        self.ramUsedBytes = ramUsedBytes
        self.ramTotalBytes = ramTotalBytes
        self.thermalState = thermalState
        self.uptimeSeconds = uptimeSeconds
        self.awakeSeconds = awakeSeconds
    }
}
