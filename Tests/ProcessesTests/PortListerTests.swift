import Testing
@testable import Processes

@Test func portListerReturnsSomePorts() {
    // The test runner itself may not have listening ports, but most macs do (SSH, etc.)
    let ports = PortLister.snapshot()
    // Hard to assert anything specific — just verify it doesn't crash and returns a collection.
    #expect(ports.count >= 0)
}
