import Foundation
import AppKit
import Carbon.HIToolbox

public final class GlobalHotkeys {
    private var refs: [EventHotKeyRef?] = []
    private var handlers: [() -> Void] = []
    private var eventHandler: EventHandlerRef?

    public init() {}

    /// Register Cmd+N (N = 1..9). Returns true if registered.
    @discardableResult
    public func register(cmdNumber n: Int, action: @escaping () -> Void) -> Bool {
        guard n >= 1, n <= 9 else { return false }
        // Key codes for 1-9 on a US keyboard layout
        let keyCode: UInt32 = UInt32([0x12, 0x13, 0x14, 0x15, 0x17, 0x16, 0x1A, 0x1C, 0x19][n - 1])
        let modifiers: UInt32 = UInt32(cmdKey)

        if eventHandler == nil { installHandler() }

        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(0x4D43_434B), id: UInt32(handlers.count))
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        guard status == noErr else { return false }
        refs.append(hotKeyRef)
        handlers.append(action)
        return true
    }

    public func unregisterAll() {
        for ref in refs { if let r = ref { UnregisterEventHotKey(r) } }
        refs.removeAll()
        handlers.removeAll()
    }

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), { (_, eventRef, userData) -> OSStatus in
            var hkID = EventHotKeyID()
            GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            guard let userData = userData else { return noErr }
            let me = Unmanaged<GlobalHotkeys>.fromOpaque(userData).takeUnretainedValue()
            let idx = Int(hkID.id)
            if idx >= 0 && idx < me.handlers.count { me.handlers[idx]() }
            return noErr
        }, 1, &eventType, selfPtr, &eventHandler)
    }
}
