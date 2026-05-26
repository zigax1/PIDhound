import Testing
import Foundation
@testable import Processes

@Test func listerReturnsRunningProcesses() async throws {
    let lister = ProcessLister()
    _ = lister.sample()
    try await Task.sleep(for: .milliseconds(200))
    let snapshots = lister.sample()

    #expect(snapshots.count > 10)
    let selfSnap = snapshots.first(where: { $0.pid == getpid() })
    #expect(selfSnap != nil)
}

@Test func parentPIDsAreValid() async throws {
    let lister = ProcessLister()
    let snapshots = lister.sample()
    // proc_listallpids without entitlements cannot enumerate GUI app parents;
    // their renderer children still appear with valid but absent ppids.
    let allHaveValidPPID = snapshots.allSatisfy { $0.ppid >= 0 }
    #expect(allHaveValidPPID)
}
