import Testing
import Foundation
@testable import Sensors

@Test func memoryReadingIsCoherent() {
    let sampler = MemorySampler()
    let reading = sampler.sample()
    #expect(reading.totalBytes > 0)
    #expect(reading.usedBytes > 0)
    #expect(reading.usedBytes <= reading.totalBytes)
    #expect(reading.totalBytes >= 4_000_000_000)
}
