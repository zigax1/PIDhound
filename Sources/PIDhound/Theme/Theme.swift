import SwiftUI

public struct Theme: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let displayName: String

    public let background: Color
    public let surface: Color
    public let surfaceElevated: Color
    public let border: Color

    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color

    public let accent: Color
    public let accentMuted: Color

    public let success: Color
    public let warning: Color
    public let danger: Color

    public let rowHover: Color
    public let cpuHigh: Color
    public let cpuCritical: Color
    public let thermalAlert: Color
    public let thermalCritical: Color

    public init(
        id: String, displayName: String,
        background: Color, surface: Color, surfaceElevated: Color, border: Color,
        textPrimary: Color, textSecondary: Color, textTertiary: Color,
        accent: Color, accentMuted: Color,
        success: Color, warning: Color, danger: Color,
        rowHover: Color,
        cpuHigh: Color, cpuCritical: Color,
        thermalAlert: Color, thermalCritical: Color
    ) {
        self.id = id; self.displayName = displayName
        self.background = background; self.surface = surface
        self.surfaceElevated = surfaceElevated; self.border = border
        self.textPrimary = textPrimary; self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.accent = accent; self.accentMuted = accentMuted
        self.success = success; self.warning = warning; self.danger = danger
        self.rowHover = rowHover
        self.cpuHigh = cpuHigh; self.cpuCritical = cpuCritical
        self.thermalAlert = thermalAlert; self.thermalCritical = thermalCritical
    }
}
