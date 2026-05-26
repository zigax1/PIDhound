import Foundation
import ServiceManagement

public enum LaunchAtLoginController {
    public static func setEnabled(_ enabled: Bool) {
        // SMAppService.mainApp only works when running from a proper .app bundle.
        // When running via `swift run pidhound` (bare exe), Bundle.main has no
        // bundle identifier — silently no-op.
        guard isRunningFromAppBundle else {
            FileHandle.standardError.write(Data("[LaunchAtLogin] Skipped (run from .app bundle for this to take effect)\n".utf8))
            return
        }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                // Only unregister if we were registered. Calling unregister on an unregistered service errors.
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            FileHandle.standardError.write(Data("[LaunchAtLogin] \(error.localizedDescription)\n".utf8))
        }
    }

    public static var isEnabled: Bool {
        guard isRunningFromAppBundle else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    private static var isRunningFromAppBundle: Bool {
        // A proper .app bundle has a CFBundleIdentifier set in Info.plist.
        // Bare swift run executables don't.
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundleIdentifier != ""
            && Bundle.main.bundlePath.hasSuffix(".app")
    }
}
