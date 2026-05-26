import SwiftUI
import Shortcuts

public struct ShortcutsPane: View {
    @Bindable var store: ShortcutsStore
    @State private var selectedId: UUID?

    public init(store: ShortcutsStore) { self.store = store }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shortcuts")
                .font(.system(size: 13, weight: .semibold))
            List(store.shortcuts, selection: $selectedId) { s in
                HStack {
                    Text(s.name)
                    Spacer()
                    if let kb = s.keybind {
                        Text(kb).font(.system(size: 11, design: .monospaced)).foregroundStyle(.secondary)
                    }
                }.tag(s.id)
            }
            HStack {
                Button(action: { /* v1.x — add new */ }) { Image(systemName: "plus") }
                    .disabled(true)
                    .help("Custom shortcut editor coming in v1.x")
                Button(action: { if let id = selectedId { store.delete(id: id) } }) { Image(systemName: "minus") }
                    .disabled(selectedId == nil)
                Spacer()
                Text("Reseed defaults").font(.caption).foregroundStyle(.secondary)
                Button("Reseed") { store.reseed() }
            }
        }
        .padding(16)
    }
}
