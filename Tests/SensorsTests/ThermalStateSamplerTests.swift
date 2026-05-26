import Testing
import Foundation
@testable import Sensors

@Test func thermalStateIsValid() {
    let sampler = ThermalStateSampler()
    let state = sampler.sample()
    #expect(ThermalState.allCases.contains(state))
}
