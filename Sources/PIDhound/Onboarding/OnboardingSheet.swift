import SwiftUI

public struct OnboardingSheet: View {
    @Bindable var settings: SettingsStore
    public let onDone: () -> Void
    @State private var step: Int = 0

    public init(settings: SettingsStore, onDone: @escaping () -> Void) {
        self.settings = settings
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: 20) {
            switch step {
            case 0: welcome
            case 1: launchStep
            default: done
            }
            Spacer()
            HStack {
                if step > 0 { Button("Back") { step -= 1 } }
                Spacer()
                if step < 2 {
                    Button("Next") { step += 1 }.keyboardShortcut(.return)
                } else {
                    Button("Get Started") {
                        settings.hasCompletedOnboarding = true
                        onDone()
                    }.keyboardShortcut(.return)
                }
            }
        }
        .padding(32)
        .frame(width: 480, height: 360)
    }

    private var welcome: some View {
        VStack(spacing: 12) {
            Image(systemName: "thermometer.medium").font(.system(size: 56)).foregroundStyle(Color.accentColor)
            Text("Welcome to PIDhound").font(.title2).fontWeight(.semibold)
            Text("PIDhound watches your Mac and your AI/dev workflow processes. By default it runs without any setup. No telemetry, no API keys, no sudo.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private var launchStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "power").font(.system(size: 40)).foregroundStyle(Color.accentColor)
            Text("Launch at login?").font(.title3)
            Toggle("Start PIDhound automatically", isOn: $settings.launchAtLogin)
                .toggleStyle(.switch)
            Text("Recommended — this way the menu bar icon is always there when you need it.")
                .font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var done: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 56)).foregroundStyle(.green)
            Text("You're set").font(.title2).fontWeight(.semibold)
            Text("Look in the top-right of your screen for the PIDhound icon. Click it any time to see vitals and stale processes.")
                .multilineTextAlignment(.center).foregroundStyle(.secondary)
        }
    }
}
