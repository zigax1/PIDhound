import Foundation
import Sensors
import Processes
import Grouping
import Persistence

public struct TickResult: Sendable {
    public let vitals: VitalsSnapshot
    public let groups: [Group]
    public let classified: [ClassifiedProcess]
    public let timestamp: Date
}

public final class SamplingEngine: @unchecked Sendable {
    private let database: Database
    private let vitalsSampler = VitalsSampler()
    private let processLister = ProcessLister()
    private let activity = ProcessActivityTracker()
    private let classifier: Classifier
    private let groupBuilder: GroupBuilder

    public private(set) var lastPersistenceError: Error?

    public init(database: Database) throws {
        self.database = database
        let rules = try RulesFile.loadBundled()
        self.classifier = Classifier(rules: rules)
        self.groupBuilder = GroupBuilder(rules: rules)
    }

    public func tick(at now: Date = Date()) -> TickResult {
        let vitals = vitalsSampler.sample(at: now)
        let processes = processLister.sample(at: now)
        activity.record(processes: processes, at: now)
        let livePIDs = Set(processes.map { $0.pid })
        activity.pruneDead(livePIDs: livePIDs)
        let classified = classifier.classify(processes: processes, activity: activity, livePIDs: livePIDs)
        let groups = groupBuilder.build(from: classified)
        return TickResult(vitals: vitals, groups: groups, classified: classified, timestamp: now)
    }

    public func tickAndPersist(at now: Date = Date()) -> TickResult {
        let result = tick(at: now)
        do {
            try VitalsSampleRecord.insert(snapshot: result.vitals, into: database)
            try ProcessSampleRecord.insert(classified: result.classified, timestamp: result.timestamp, into: database)
            lastPersistenceError = nil
        } catch {
            lastPersistenceError = error
            FileHandle.standardError.write(Data("[SamplingEngine] persistence error: \(error)\n".utf8))
        }
        return result
    }
}
