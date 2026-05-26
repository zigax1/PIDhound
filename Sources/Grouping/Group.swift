import Foundation
import Processes

public struct Group: Equatable, Sendable {
    public let id: String
    public let label: String
    public let order: Int
    public let processes: [ClassifiedProcess]
    public let totalCPUPercent: Double
    public let totalRSSBytes: UInt64
    public let staleCount: Int

    public init(id: String, label: String, order: Int, processes: [ClassifiedProcess], totalCPUPercent: Double, totalRSSBytes: UInt64, staleCount: Int) {
        self.id = id
        self.label = label
        self.order = order
        self.processes = processes
        self.totalCPUPercent = totalCPUPercent
        self.totalRSSBytes = totalRSSBytes
        self.staleCount = staleCount
    }
}
