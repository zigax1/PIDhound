import Testing
import Foundation
@testable import Sensors

@Test func snapshotIsCodable() throws {
    let snap = VitalsSnapshot(
        timestamp: Date(timeIntervalSince1970: 1_700_000_000),
        cpuPercent: 73.5,
        ramUsedBytes: 21_400_000_000,
        ramTotalBytes: 34_359_738_368,
        thermalState: .moderate,
        uptimeSeconds: 2_000_000,
        awakeSeconds: 30_000
    )
    let encoded = try JSONEncoder().encode(snap)
    let decoded = try JSONDecoder().decode(VitalsSnapshot.self, from: encoded)
    #expect(decoded == snap)
}

@Test func thermalStateOrdering() {
    #expect(ThermalState.nominal < ThermalState.moderate)
    #expect(ThermalState.moderate < ThermalState.heavy)
    #expect(ThermalState.heavy < ThermalState.critical)
}
