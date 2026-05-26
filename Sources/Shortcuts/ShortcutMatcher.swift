import Foundation
import Processes

public enum ShortcutMatcher {
    public static func resolve(_ spec: MatchSpec, against classified: [ClassifiedProcess]) -> [ClassifiedProcess] {
        switch spec {
        case .group(let id, let tagsAny):
            let members = classified.filter { $0.groupId == id }
            if tagsAny.isEmpty { return members }
            let tagSet = Set(tagsAny)
            return members.filter { !Set($0.stateTags).isDisjoint(with: tagSet) }
        case .namePattern(let needle):
            let lower = needle.lowercased()
            return classified.filter { c in
                c.snapshot.name.lowercased().contains(lower) ||
                c.snapshot.argv.joined(separator: " ").lowercased().contains(lower)
            }
        case .port(let port):
            let portStr = String(port)
            return classified.filter { c in
                c.snapshot.argv.contains(where: { $0.contains(":\(portStr)") || $0 == portStr })
            }
        case .ancestorName(let name):
            // v1 limitation: we don't have a full ancestor chain. Match if direct parent (by pid) has this name.
            let byPid = Dictionary(uniqueKeysWithValues: classified.map { ($0.snapshot.pid, $0) })
            return classified.filter { c in
                guard let parent = byPid[c.snapshot.ppid] else { return false }
                return parent.snapshot.name.lowercased().contains(name.lowercased())
            }
        case .composedOr(let specs):
            var seen: Set<Int32> = []
            var out: [ClassifiedProcess] = []
            for sub in specs {
                for match in resolve(sub, against: classified) where !seen.contains(match.snapshot.pid) {
                    seen.insert(match.snapshot.pid)
                    out.append(match)
                }
            }
            return out
        }
    }
}
