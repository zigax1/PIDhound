import Foundation

public final class Classifier: Sendable {
    private let rules: RulesFile

    public init(rules: RulesFile) {
        self.rules = RulesFile(
            version: rules.version,
            groups: rules.groups.sorted { $0.order < $1.order }
        )
    }

    public func classify(
        processes: [ProcessSnapshot],
        activity: ProcessActivityTracker,
        livePIDs: Set<Int32>? = nil
    ) -> [ClassifiedProcess] {
        let alive = livePIDs ?? Set(processes.map { $0.pid })
        return processes.map { proc in
            let groupId = findGroup(for: proc) ?? "other"
            let tags = computeStateTags(proc: proc, groupId: groupId, activity: activity, livePIDs: alive)
            return ClassifiedProcess(snapshot: proc, groupId: groupId, stateTags: tags)
        }
    }

    private func findGroup(for proc: ProcessSnapshot) -> String? {
        for rule in rules.groups where rule.id != "other" {
            if matches(rule.match, proc: proc) { return rule.id }
        }
        return nil
    }

    private func matches(_ match: MatchRule, proc: ProcessSnapshot) -> Bool {
        var anyConditionPresent = false
        var allConditionsMet = true

        if let names = match.processName, !names.isEmpty {
            anyConditionPresent = true
            let argv0 = proc.argv.first.map { ($0 as NSString).lastPathComponent } ?? ""
            let matched = names.contains(where: { needle in
                proc.name == needle
                || proc.name.contains(needle)
                || proc.executablePath.hasSuffix("/" + needle)
                || argv0 == needle
                || argv0.contains(needle)
            })
            if !matched {
                allConditionsMet = false
            }
        }

        if allConditionsMet, let needles = match.argvContains, !needles.isEmpty {
            anyConditionPresent = true
            let joined = proc.argv.joined(separator: " ")
            if !needles.contains(where: { joined.contains($0) }) {
                allConditionsMet = false
            }
        }

        return anyConditionPresent && allConditionsMet
    }

    func computeStateTags(
        proc: ProcessSnapshot,
        groupId: String,
        activity: ProcessActivityTracker,
        livePIDs: Set<Int32>
    ) -> [StateTag] {
        var tags: [StateTag] = []

        let now = Date()
        let idleSeconds = activity.idleSeconds(pid: proc.pid, now: now)

        if let rule = rules.groups.first(where: { $0.id == groupId }) {
            if let staleMin = rule.staleThresholdMinutes, idleSeconds > Double(staleMin) * 60, proc.cpuPercent < 1 {
                tags.append(.stale)
            } else if let idleMin = rule.idleThresholdMinutes, idleSeconds > Double(idleMin) * 60 {
                tags.append(.idle)
            } else if proc.cpuPercent > 1 {
                tags.append(.active)
            }
        } else if proc.cpuPercent > 1 {
            tags.append(.active)
        }

        // Orphan: parent PID is not launchd/kernel and not in live set.
        // Skip orphan flagging for groups marked never_orphan in rules.
        if proc.ppid > 1 && !livePIDs.contains(proc.ppid) {
            let rule = rules.groups.first(where: { $0.id == groupId })
            let neverOrphan = rule?.neverOrphan ?? false
            if !neverOrphan {
                tags.append(.orphan)
            }
        }

        if groupId == "playwright-browsers" && tags.contains(.orphan) {
            tags.append(.zombie)
        }

        return tags
    }
}
