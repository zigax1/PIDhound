import Testing
import Foundation
@testable import Sensors

@Test func firstSampleReturnsZeroPercent() {
    let sampler = CPUSampler()
    let first = sampler.sample()
    #expect(first.cpuPercent == 0)
}

@Test func secondSampleAfterWaitIsInRange() async throws {
    let sampler = CPUSampler()
    _ = sampler.sample()
    try await Task.sleep(for: .milliseconds(200))
    let second = sampler.sample()
    #expect(second.cpuPercent >= 0)
    #expect(second.cpuPercent <= 100)
}
