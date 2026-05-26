import Foundation

public final class VitalsSampler: @unchecked Sendable {
    private let cpu = CPUSampler()
    private let memory = MemorySampler()
    private let uptime = UptimeSampler()
    private let thermal = ThermalStateSampler()

    public init() {}

    public func sample(at now: Date = Date()) -> VitalsSnapshot {
        let cpuReading = cpu.sample()
        let memReading = memory.sample()
        let uptimeReading = uptime.sample()
        let thermalState = thermal.sample()

        return VitalsSnapshot(
            timestamp: now,
            cpuPercent: cpuReading.cpuPercent,
            ramUsedBytes: memReading.usedBytes,
            ramTotalBytes: memReading.totalBytes,
            thermalState: thermalState,
            uptimeSeconds: uptimeReading.uptimeSeconds,
            awakeSeconds: uptimeReading.awakeSeconds
        )
    }
}
