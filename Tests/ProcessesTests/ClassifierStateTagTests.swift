import Testing
import Foundation
@testable import Processes

private func proc(pid: Int32, ppid: Int32 = 1, name: String = "claude", cpu: Double = 0, startMinutesAgo: Int = 60) -> ProcessSnapshot {
    ProcessSnapshot(
        pid: pid, ppid: ppid, name: name,
        executablePath: "/bin/\(name)", argv: [name],
        cwd: nil, cpuPercent: cpu, residentSizeBytes: 100_000_000,
        startTime: Date(timeIntervalSinceNow: -Double(startMinutesAgo) * 60)
    )
}

private let tagRules = try! RulesFile.from(yaml: """
version: 1
groups:
  - id: claude-code-sessions
    label: Claude
    order: 1
    match:
      process_name: [claude]
    idle_threshold_minutes: 30
    stale_threshold_minutes: 120
  - id: playwright-browsers
    label: Playwright
    order: 2
    match:
      process_name: [Chromium]
  - id: other
    label: Other
    order: 99
    match:
      process_name: []
""")

@Test func activeWhenCPUIsAboveOne() {
    let classifier = Classifier(rules: tagRules)
    let tracker = ProcessActivityTracker()
    let result = classifier.classify(processes: [proc(pid: 1, cpu: 12)], activity: tracker)
    #expect(result[0].stateTags.contains(.active))
}

@Test func idleAfterThirtyMinutesWithNoCPU() {
    let classifier = Classifier(rules: tagRules)
    let tracker = ProcessActivityTracker()
    let p = proc(pid: 2, cpu: 0)
    let pastEvent = ProcessSnapshot(
        pid: 2, ppid: 1, name: "claude",
        executablePath: "/bin/claude", argv: ["claude"],
        cwd: nil, cpuPercent: 5, residentSizeBytes: 100,
        startTime: Date()
    )
    tracker.record(processes: [pastEvent], at: Date(timeIntervalSinceNow: -45 * 60))
    let result = classifier.classify(processes: [p], activity: tracker)
    #expect(result[0].stateTags.contains(.idle))
    #expect(!result[0].stateTags.contains(.stale))
}

@Test func staleAfterTwoHoursWithLowCPU() {
    let classifier = Classifier(rules: tagRules)
    let tracker = ProcessActivityTracker()
    let pastEvent = ProcessSnapshot(
        pid: 3, ppid: 1, name: "claude",
        executablePath: "/bin/claude", argv: ["claude"],
        cwd: nil, cpuPercent: 5, residentSizeBytes: 100,
        startTime: Date()
    )
    tracker.record(processes: [pastEvent], at: Date(timeIntervalSinceNow: -3 * 3600))
    let result = classifier.classify(processes: [proc(pid: 3, cpu: 0)], activity: tracker)
    #expect(result[0].stateTags.contains(.stale))
}

@Test func orphanWhenParentMissing() {
    let classifier = Classifier(rules: tagRules)
    let tracker = ProcessActivityTracker()
    let p = proc(pid: 4, ppid: 999)
    let result = classifier.classify(processes: [p], activity: tracker, livePIDs: [4])
    #expect(result[0].stateTags.contains(.orphan))
}

@Test func zombieIsBrowserPlusOrphan() {
    let classifier = Classifier(rules: tagRules)
    let tracker = ProcessActivityTracker()
    let p = proc(pid: 5, ppid: 888, name: "Chromium")
    let result = classifier.classify(processes: [p], activity: tracker, livePIDs: [5])
    #expect(result[0].groupId == "playwright-browsers")
    #expect(result[0].stateTags.contains(.orphan))
    #expect(result[0].stateTags.contains(.zombie))
}
