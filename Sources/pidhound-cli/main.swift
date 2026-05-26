import Foundation
import PIDhoundCore
import Persistence
import Sensors
import Processes
import Grouping

let supportDir = SupportDirectory.resolveAndMigrate()
let dbPath = "\(supportDir)/cockpit.sqlite"

print("PIDhound CLI (Plan 1)")
print("DB: \(dbPath)")

let database = try Database.atPath(dbPath)
try Migrations.runAll(on: database)
let engine = try SamplingEngine(database: database)

_ = engine.tick()
Thread.sleep(forTimeInterval: 0.5)

let debugClassify = CommandLine.arguments.contains("--debug-classify")

if debugClassify {
    print("=== One-shot classification debug ===")
    print("")

    // Parse optional --grep PATTERN
    var grepPattern: String? = nil
    if let i = CommandLine.arguments.firstIndex(of: "--grep"),
       i + 1 < CommandLine.arguments.count {
        grepPattern = CommandLine.arguments[i + 1].lowercased()
    }

    let result = engine.tick()

    func matches(_ c: ClassifiedProcess) -> Bool {
        guard let pat = grepPattern else { return true }
        if c.snapshot.name.lowercased().contains(pat) { return true }
        if c.snapshot.executablePath.lowercased().contains(pat) { return true }
        if c.snapshot.argv.joined(separator: " ").lowercased().contains(pat) { return true }
        if c.groupId.lowercased().contains(pat) { return true }
        return false
    }

    let filtered = result.classified.filter(matches)
    let byGroup = Dictionary(grouping: filtered, by: { $0.groupId })

    func printRow(_ c: ClassifiedProcess) {
        let argv0 = (c.snapshot.argv.first.map { ($0 as NSString).lastPathComponent }) ?? ""
        let tags = c.stateTags.map { $0.rawValue }.joined(separator: ",")
        let name = c.snapshot.name.padding(toLength: 35, withPad: " ", startingAt: 0)
        let argv0Padded = argv0.padding(toLength: 20, withPad: " ", startingAt: 0)
        let cpu = String(format: "%5.1f%%", c.snapshot.cpuPercent)
        let rss = humanBytes(c.snapshot.residentSizeBytes).padding(toLength: 8, withPad: " ", startingAt: 0)
        let tagStr = tags.isEmpty ? "" : "  [\(tags)]"
        print("  pid \(String(format: "%6d", c.snapshot.pid))  \(name) argv0=\(argv0Padded) cpu=\(cpu)  rss=\(rss)\(tagStr)")
    }

    if let pat = grepPattern {
        print("(filtering to processes matching '\(pat)' — \(filtered.count) of \(result.classified.count) match)")
        print("")
    }

    let nonOtherGroupIds = byGroup.keys.filter { $0 != "other" }.sorted()
    if nonOtherGroupIds.isEmpty && grepPattern == nil {
        print("(no processes matched any non-other group — classification rules need work)")
        print("")
    }
    for groupId in nonOtherGroupIds {
        let members = byGroup[groupId] ?? []
        print("== \(groupId) (\(members.count) processes) ==")
        for c in members.sorted(by: { $0.snapshot.pid < $1.snapshot.pid }) {
            printRow(c)
        }
        print("")
    }

    let others = (byGroup["other"] ?? []).sorted(by: { $0.snapshot.residentSizeBytes > $1.snapshot.residentSizeBytes })
    if !others.isEmpty {
        print("== other (\(others.count) processes) ==")
        for c in others {
            printRow(c)
        }
        print("")
    }

    print("=== Summary ===")
    print("Total processes returned by lister: \(result.classified.count)")
    for groupId in (byGroup.keys.sorted()) {
        let count = byGroup[groupId]?.count ?? 0
        print("  \(groupId): \(count)")
    }

    exit(0)
}

func humanBytes(_ b: UInt64) -> String {
    let kb = 1024.0
    let mb = kb * 1024
    let gb = mb * 1024
    let x = Double(b)
    if x >= gb { return String(format: "%.1f GB", x / gb) }
    if x >= mb { return String(format: "%.0f MB", x / mb) }
    if x >= kb { return String(format: "%.0f KB", x / kb) }
    return "\(b) B"
}

func humanDuration(_ s: TimeInterval) -> String {
    let total = Int(s)
    let days = total / 86_400
    let hours = (total % 86_400) / 3600
    let mins = (total % 3600) / 60
    if days > 0 { return "\(days)d \(hours)h \(mins)m" }
    if hours > 0 { return "\(hours)h \(mins)m" }
    return "\(mins)m"
}

func render(_ r: TickResult) {
    // Apple Terminal compat: write clear+home and explicitly flush before content.
    fputs("\u{001B}[2J\u{001B}[H", stdout)
    fflush(stdout)

    let v = r.vitals
    print("PIDhound  -  \(Date().formatted(.dateTime))")
    print("CPU \(String(format: "%.1f", v.cpuPercent))%  |  RAM \(humanBytes(v.ramUsedBytes)) / \(humanBytes(v.ramTotalBytes))  |  Thermal \(v.thermalState.rawValue.uppercased())")
    print("Uptime \(humanDuration(v.uptimeSeconds))  |  Awake \(humanDuration(v.awakeSeconds))")
    print(String(repeating: "-", count: 80))

    // Stale count: EXCLUDE the "other" group so we don't scare with system noise.
    let actionableGroups = r.groups.filter { $0.id != "other" }
    let staleActionable = actionableGroups.reduce(0) { $0 + $1.staleCount }
    let staleOther = r.groups.first(where: { $0.id == "other" })?.staleCount ?? 0
    if staleActionable > 0 {
        print("[!] \(staleActionable) stale items in dev/AI workflows  (plus \(staleOther) in system/other - hidden)")
        print(String(repeating: "-", count: 80))
    } else if staleOther > 0 {
        print("    No stale items in dev/AI workflows  (\(staleOther) in system/other - hidden)")
        print(String(repeating: "-", count: 80))
    }

    // Render actionable groups
    for group in actionableGroups {
        let mark = group.staleCount > 0 ? "[!] " : "    "
        print("\(mark)\(group.label) (\(group.processes.count))  \(String(format: "%.1f", group.totalCPUPercent))%  \(humanBytes(group.totalRSSBytes))")
        for c in group.processes.sorted(by: { $0.snapshot.cpuPercent > $1.snapshot.cpuPercent }).prefix(5) {
            let tags = c.stateTags.map { $0.rawValue }.joined(separator: ",")
            let tagStr = tags.isEmpty ? "" : "  [\(tags)]"
            print("      pid \(c.snapshot.pid)  \(c.snapshot.name)  \(String(format: "%.1f", c.snapshot.cpuPercent))%  \(humanBytes(c.snapshot.residentSizeBytes))\(tagStr)")
        }
    }

    // Show Other group totals only (no per-process detail - that's the system noise)
    if let other = r.groups.first(where: { $0.id == "other" }), !other.processes.isEmpty {
        print(String(repeating: "-", count: 80))
        print("    Other / System (\(other.processes.count))  \(String(format: "%.1f", other.totalCPUPercent))%  \(humanBytes(other.totalRSSBytes))  [collapsed]")
    }
}

while true {
    let result = engine.tickAndPersist()
    render(result)
    Thread.sleep(forTimeInterval: 2)
}
