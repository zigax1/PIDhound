import Foundation
import Observation
import Sensors
import Processes
import Grouping
import Persistence
import PIDhoundCore

@Observable
@MainActor
public final class AppState {
    private let engine: SamplingEngine
    private var timer: Timer?

    public private(set) var latestVitals: VitalsSnapshot?
    public private(set) var latestGroups: [Group] = []
    public private(set) var latestClassified: [ClassifiedProcess] = []
    public private(set) var latestTickAt: Date?
    public private(set) var errorMessage: String?

    public func clearError() { errorMessage = nil }

    public init(database: Database) throws {
        self.engine = try SamplingEngine(database: database)
    }

    public func startSampling(intervalSeconds: TimeInterval = 2) {
        stopSampling()
        let _ = engine.tick()
        let t = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tickOnce() }
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    public func stopSampling() {
        timer?.invalidate()
        timer = nil
    }

    public func tickOnce() {
        let result = engine.tickAndPersist()
        latestVitals = result.vitals
        latestGroups = result.groups
        latestClassified = result.classified
        latestTickAt = result.timestamp
        if let err = engine.lastPersistenceError {
            errorMessage = "Persistence error: \(err.localizedDescription)"
        }
    }

    public var staleCountActionable: Int {
        latestGroups.filter { $0.id != "other" }.reduce(0) { $0 + $1.staleCount }
    }

    public var staleCountOther: Int {
        latestGroups.first(where: { $0.id == "other" })?.staleCount ?? 0
    }

    public var actionableGroups: [Group] {
        latestGroups.filter { $0.id != "other" }.sorted(by: { $0.order < $1.order })
    }

    public var otherGroup: Group? {
        latestGroups.first(where: { $0.id == "other" })
    }
}
