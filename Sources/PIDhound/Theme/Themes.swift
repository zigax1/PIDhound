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
        danger: Color(red: 0.980, green: 0.455, blue: 0.455)
    )

    public static let terminalGreen = Theme(
        id: "terminal-green", displayName: "Terminal Green",
        background: Color(red: 0.020, green: 0.031, blue: 0.020),
        surface: Color(red: 0.039, green: 0.078, blue: 0.039),
        surfaceElevated: Color(red: 0.059, green: 0.118, blue: 0.059),
        border: Color(red: 0.102, green: 0.227, blue: 0.122),
        textPrimary: Color(red: 0.306, green: 1.0, blue: 0.557),
        textSecondary: Color(red: 0.306, green: 1.0, blue: 0.557).opacity(0.7),
        textTertiary: Color(red: 0.306, green: 1.0, blue: 0.557).opacity(0.5),
        accent: Color(red: 0.306, green: 1.0, blue: 0.557),
        accentMuted: Color(red: 0.306, green: 1.0, blue: 0.557).opacity(0.15),
        success: Color(red: 0.306, green: 1.0, blue: 0.557),
        warning: Color(red: 1.0, green: 0.824, blue: 0.306),
        danger: Color(red: 1.0, green: 0.392, blue: 0.392)
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
        success: Color(red: 1.0, green: 0.722, blue: 0.302),
        warning: Color(red: 1.0, green: 0.549, blue: 0.165),
        danger: Color(red: 1.0, green: 0.353, blue: 0.235)
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
        success: Color(red: 0.0, green: 0.941, blue: 1.0),
        warning: Color(red: 1.0, green: 0.0, blue: 0.667),
        danger: Color(red: 1.0, green: 0.200, blue: 0.400)
    )

    public static let bundled: [Theme] = [.modern, .terminalGreen, .cyberdeckAmber, .neonCyber]
}
