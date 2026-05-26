import Testing
import SwiftUI
@testable import PIDhound

@Test func themeIsHashableAndIdentifiable() {
    let modern = Theme.modern
    let same = Theme.modern
    #expect(modern.id == same.id)
    #expect(modern == same)
}

@Test func allBundledThemesHaveUniqueIDs() {
    let ids = Set(Theme.bundled.map { $0.id })
    #expect(ids.count == Theme.bundled.count)
    #expect(Theme.bundled.count == 4)
}
