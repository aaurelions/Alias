import SwiftUI
import Combine

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var current: ThemeColors

    private init() {
        self.current = .dark
    }

    func switchTheme(to theme: ThemeColors) {
        current = theme
    }
}

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
        // A sophisticated and modern slate gray theme
        backgroundTop: Color.blue,
        backgroundMiddle: Color.black,
        backgroundBottom: Color.indigo,

        // Base backgrounds for UI elements
        backgroundPrimary: Color(hex: "#2D2D2D"),   // Dark gray for main background
        backgroundSecondary: Color(hex: "#3C3C3F"), // Slightly lighter gray for secondary areas

        // Surfaces for cards, modals, etc.
        surfacePrimary: Color(hex: "#4A4A4D"),       // Elevated surface gray
        surfaceSecondary: Color(hex: "#58585B"),    // Lighter gray for secondary surfaces

        // Interactive elements for buttons, links, etc.
        interactivePrimary: Color(hex: "6ca9d1"),
        interactiveSecondary: Color(hex: "#8E8E93"),// Muted gray for secondary actions

        // Text colors for readability
        textPrimary: Color(hex: "#F2F2F7"),          // Soft off-white for high contrast
        textSecondary: Color(hex: "#AEAEB2"),        // Lighter gray for secondary text

        // Borders for subtle separation
        borderPrimary: Color(hex: "#545458"),        // Visible but subtle mid-gray

        // Semantic accent colors
        accentHighlight: Color(hex: "#0A84FF"),      // Cool blue for info
        accentDestructive: Color(hex: "#FF453A"),    // A vibrant red for danger
        accentSuccess: Color(hex: "#30D158"),        // A clear, bright green for success
        accentWarning: Color(hex: "#FF9F0A")         // A warm orange for warnings
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
