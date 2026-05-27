import Testing
import SwiftUI
@testable import PIDhound

@Test func killButtonStoresPidAndTooltip() {
    var called = false
    let button = KillButton(pid: 4242, tooltip: "Kill PID 4242 — frees port 5173") {
        called = true
    }
    #expect(button.pid == 4242)
    #expect(button.tooltip == "Kill PID 4242 — frees port 5173")
    button.action()
    #expect(called == true)
}

@Test func killButtonDefaultsTooltipToPidLabel() {
    let button = KillButton(pid: 99) { }
    #expect(button.tooltip == "Kill PID 99")
}
