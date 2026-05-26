import Testing
import Foundation
@testable import Sensors

@Test func uptimeIsPositiveAndReasonable() {
    let sampler = UptimeSampler()
    let snap = sampler.sample()
    #expect(snap.uptimeSeconds > 0)
    #expect(snap.uptimeSeconds < 5 * 365 * 24 * 3600)
}

@Test func awakeIsAtMostUptime() {
    let sampler = UptimeSampler()
    let snap = sampler.sample()
    #expect(snap.awakeSeconds <= snap.uptimeSeconds)
    #expect(snap.awakeSeconds >= 0)
}
