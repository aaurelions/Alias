import SwiftUI

// MARK: - Theme Colors

public struct ThemeColors {
    let backgroundTop: Color
    let backgroundMiddle: Color
    let backgroundBottom: Color
    let backgroundPrimary: Color
    let backgroundSecondary: Color
    let surfacePrimary: Color
    let surfaceSecondary: Color
    let interactivePrimary: Color
    let interactiveSecondary: Color
    let textPrimary: Color
    let textSecondary: Color
    let borderPrimary: Color
    let accentHighlight: Color
    let accentDestructive: Color
    let accentSuccess: Color
    let accentWarning: Color
}

// MARK: - Theme Presets

extension ThemeColors {
    public static let dark = ThemeColors(
        backgroundTop: Color.blue,
        backgroundMiddle: Color.black,
        backgroundBottom: Color.indigo,

        backgroundPrimary: Color(hex: "#2D2D2D"),
        backgroundSecondary: Color(hex: "#3C3C3F"),

        surfacePrimary: Color(hex: "#4A4A4D"),
        surfaceSecondary: Color(hex: "#58585B"),

        interactivePrimary: Color(hex: "6ca9d1"),
        interactiveSecondary: Color(hex: "#8E8E93"),

        textPrimary: Color(hex: "#F2F2F7"),
        textSecondary: Color(hex: "#AEAEB2"),

        borderPrimary: Color(hex: "#545458"),

        accentHighlight: Color(hex: "#0A84FF"),
        accentDestructive: Color(hex: "#FF453A"),
        accentSuccess: Color(hex: "#30D158"),
        accentWarning: Color(hex: "#FF9F0A")
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
