import Testing
import Foundation
@testable import PIDhoundCore
@testable import Persistence

@Test func samplingTickIsFast() async throws {
    let db = try Database.inMemory()
    try Migrations.runAll(on: db)
    let engine = try SamplingEngine(database: db)
    _ = engine.tick()  // warmup
    try await Task.sleep(for: .milliseconds(100))

    let start = Date()
    _ = engine.tickAndPersist()
    let elapsed = Date().timeIntervalSince(start)

    // Target: < 500ms per tick on a typical Mac with ~500 processes.
    #expect(elapsed < 0.5, "Sampling tick took \(elapsed)s")
}
