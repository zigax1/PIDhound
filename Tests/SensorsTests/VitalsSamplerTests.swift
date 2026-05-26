import Testing
import Foundation
@testable import Sensors

@Test func vitalsSamplerProducesCompleteSnapshot() async throws {
    let sampler = VitalsSampler()
    _ = sampler.sample()
    try await Task.sleep(for: .milliseconds(150))
    let snap = sampler.sample()

    #expect(snap.cpuPercent >= 0 && snap.cpuPercent <= 100)
    #expect(snap.ramTotalBytes > 0)
    #expect(snap.uptimeSeconds > 0)
    #expect(ThermalState.allCases.contains(snap.thermalState))
}
