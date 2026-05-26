import Foundation
import Processes

public struct GroupBuilder: Sendable {
    private let rules: RulesFile

    public init(rules: RulesFile) {
        self.rules = rules
    }

    public func build(from classified: [ClassifiedProcess]) -> [Group] {
        let byGroup = Dictionary(grouping: classified, by: { $0.groupId })
        let staleTags: Set<StateTag> = [.stale, .orphan, .zombie]

        var groups: [Group] = []
        for rule in rules.groups.sorted(by: { $0.order < $1.order }) {
            let members = byGroup[rule.id] ?? []
            guard !members.isEmpty else { continue }
            let totalCPU = members.reduce(0.0) { $0 + $1.snapshot.cpuPercent }
            let totalRSS = members.reduce(UInt64(0)) { $0 + $1.snapshot.residentSizeBytes }
            let stale = members.filter { !staleTags.isDisjoint(with: Set($0.stateTags)) }.count
            groups.append(Group(
                id: rule.id, label: rule.label, order: rule.order,
                processes: members, totalCPUPercent: totalCPU,
                totalRSSBytes: totalRSS, staleCount: stale
            ))
        }
        return groups
    }
}
