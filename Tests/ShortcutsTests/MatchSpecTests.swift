import Testing
import Foundation
@testable import Shortcuts
@testable import Processes

@Test func matchSpecGroupRoundtrip() throws {
    let spec = MatchSpec.group(id: "mcp-servers", tagsAny: [.orphan])
    let encoded = try JSONEncoder().encode(spec)
    let decoded = try JSONDecoder().decode(MatchSpec.self, from: encoded)
    #expect(decoded == spec)
}

@Test func matchSpecPortRoundtrip() throws {
    let spec = MatchSpec.port(5173)
    let encoded = try JSONEncoder().encode(spec)
    let decoded = try JSONDecoder().decode(MatchSpec.self, from: encoded)
    #expect(decoded == spec)
}

@Test func shortcutRoundtrip() throws {
    let s = Shortcut(name: "Kill orphan MCPs", match: .group(id: "mcp-servers", tagsAny: [.orphan]), keybind: "cmd+1")
    let encoded = try JSONEncoder().encode(s)
    let decoded = try JSONDecoder().decode(Shortcut.self, from: encoded)
    #expect(decoded.name == s.name)
    #expect(decoded.match == s.match)
}
