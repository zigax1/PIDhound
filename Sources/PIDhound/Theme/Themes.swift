import SwiftUI

extension Theme {
    public static let modern = Theme(
        id: "modern", displayName: "Modern",
        background: Color(red: 0.043, green: 0.043, blue: 0.051),
        surface: Color(red: 0.110, green: 0.110, blue: 0.125),
        surfaceElevated: Color(red: 0.145, green: 0.145, blue: 0.165),
        border: Color(red: 0.220, green: 0.220, blue: 0.250),
        textPrimary: Color(red: 0.945, green: 0.945, blue: 0.953),
        textSecondary: Color(red: 0.635, green: 0.635, blue: 0.675),
        textTertiary: Color(red: 0.475, green: 0.475, blue: 0.510),
        accent: Color(red: 0.302, green: 0.890, blue: 0.522),
        accentMuted: Color(red: 0.302, green: 0.890, blue: 0.522).opacity(0.18),
        success: Color(red: 0.302, green: 0.890, blue: 0.522),
        warning: Color(red: 0.975, green: 0.769, blue: 0.475),
        danger: Color(red: 0.980, green: 0.455, blue: 0.455),
        rowHover: Color.white.opacity(0.05),
        cpuHigh: Color(red: 1.0, green: 0.706, blue: 0.290),
        cpuCritical: Color(red: 1.0, green: 0.396, blue: 0.388),
        thermalAlert: Color(red: 1.0, green: 0.541, blue: 0.227),
        thermalCritical: Color(red: 1.0, green: 0.275, blue: 0.275)
    )

    public static let terminalGreen = Theme(
        id: "terminal-green", displayName: "Terminal Green",
        background: Color(red: 0.024, green: 0.039, blue: 0.027),
        surface: Color(red: 0.043, green: 0.071, blue: 0.047),
        surfaceElevated: Color(red: 0.063, green: 0.106, blue: 0.071),
        border: Color(red: 0.094, green: 0.184, blue: 0.118),
        textPrimary: Color(red: 0.345, green: 0.831, blue: 0.557),
        textSecondary: Color(red: 0.345, green: 0.831, blue: 0.557).opacity(0.70),
        textTertiary: Color(red: 0.345, green: 0.831, blue: 0.557).opacity(0.45),
        accent: Color(red: 0.408, green: 0.871, blue: 0.620),
        accentMuted: Color(red: 0.408, green: 0.871, blue: 0.620).opacity(0.15),
        success: Color(red: 0.408, green: 0.871, blue: 0.620),
        warning: Color(red: 0.965, green: 0.788, blue: 0.353),
        danger: Color(red: 0.965, green: 0.420, blue: 0.420),
        rowHover: Color(red: 0.408, green: 0.871, blue: 0.620).opacity(0.10),
        cpuHigh: Color(red: 0.965, green: 0.788, blue: 0.353),
        cpuCritical: Color(red: 1.0, green: 0.439, blue: 0.376),
        thermalAlert: Color(red: 0.965, green: 0.667, blue: 0.298),
        thermalCritical: Color(red: 1.0, green: 0.341, blue: 0.341)
    )

    public static let cyberdeckAmber = Theme(
        id: "cyberdeck-amber", displayName: "Cyberdeck Amber",
        background: Color(red: 0.039, green: 0.031, blue: 0.020),
        surface: Color(red: 0.078, green: 0.051, blue: 0.031),
        surfaceElevated: Color(red: 0.118, green: 0.078, blue: 0.047),
        border: Color(red: 0.290, green: 0.180, blue: 0.063),
        textPrimary: Color(red: 1.0, green: 0.722, blue: 0.302),
        textSecondary: Color(red: 1.0, green: 0.722, blue: 0.302).opacity(0.7),
        textTertiary: Color(red: 1.0, green: 0.722, blue: 0.302).opacity(0.5),
        accent: Color(red: 1.0, green: 0.722, blue: 0.302),
        accentMuted: Color(red: 1.0, green: 0.722, blue: 0.302).opacity(0.15),
        success: Color(red: 0.518, green: 0.890, blue: 0.435),
        warning: Color(red: 1.0, green: 0.937, blue: 0.314),
        danger: Color(red: 1.0, green: 0.353, blue: 0.235),
        rowHover: Color(red: 1.0, green: 0.722, blue: 0.302).opacity(0.10),
        cpuHigh: Color(red: 1.0, green: 0.937, blue: 0.314),
        cpuCritical: Color(red: 1.0, green: 0.349, blue: 0.227),
        thermalAlert: Color(red: 1.0, green: 0.937, blue: 0.314),
        thermalCritical: Color(red: 1.0, green: 0.290, blue: 0.196)
    )

    public static let neonCyber = Theme(
        id: "neon-cyber", displayName: "Neon Cyber",
        background: Color(red: 0.039, green: 0.020, blue: 0.094),
        surface: Color(red: 0.078, green: 0.039, blue: 0.157),
        surfaceElevated: Color(red: 0.118, green: 0.059, blue: 0.220),
        border: Color(red: 0.165, green: 0.102, blue: 0.290),
        textPrimary: Color(red: 0.812, green: 0.914, blue: 1.0),
        textSecondary: Color(red: 0.812, green: 0.914, blue: 1.0).opacity(0.7),
        textTertiary: Color(red: 0.812, green: 0.914, blue: 1.0).opacity(0.5),
        accent: Color(red: 0.0, green: 0.941, blue: 1.0),
        accentMuted: Color(red: 0.0, green: 0.941, blue: 1.0).opacity(0.15),
        success: Color(red: 0.471, green: 1.0, blue: 0.620),
        warning: Color(red: 1.0, green: 0.851, blue: 0.314),
        danger: Color(red: 1.0, green: 0.200, blue: 0.400),
        rowHover: Color(red: 0.0, green: 0.941, blue: 1.0).opacity(0.10),
        cpuHigh: Color(red: 1.0, green: 0.851, blue: 0.314),
        cpuCritical: Color(red: 1.0, green: 0.275, blue: 0.580),
        thermalAlert: Color(red: 1.0, green: 0.290, blue: 0.871),
        thermalCritical: Color(red: 1.0, green: 0.220, blue: 0.420)
    )

    public static let bundled: [Theme] = [.modern, .terminalGreen, .cyberdeckAmber, .neonCyber]
}
