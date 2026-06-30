import SwiftUI

/// A comprehensive design system for the Alias game
/// Following Swift best practices with type-safe design tokens
public struct Theme {

    // MARK: - Colors

    public struct Colors {
        public let backgroundTop: Color
        public let backgroundMiddle: Color
        public let backgroundBottom: Color

        // Backgrounds: The inky, textured darkness of the room's deepest shadows.
        public let backgroundPrimary: Color
        public let backgroundSecondary: Color

        // Surfaces: Layers of dark teal and blue, like the moonlit wall.
        public let surfacePrimary: Color
        public let surfaceSecondary: Color

        // Interactive: Muted, desaturated blues that emerge from the gloom.
        public let interactivePrimary: Color
        public let interactiveSecondary: Color

        // Text: Inspired by the lightest furs, offering clarity without harshness.
        public let textPrimary: Color
        public let textSecondary: Color

        // Borders: A barely-there line of dark slate to define edges.
        public let borderPrimary: Color

        // Semantic: The vibrant life of the creatures, used as meaningful accents.
        public let accentHighlight: Color  // The electric blue fur
        public let accentDestructive: Color // The rich orange fur
        public let accentSuccess: Color     // A deep, foliage-inspired green
        public let accentWarning: Color     // The golden-yellow fur

        public init(
            backgroundTop: Color,
            backgroundMiddle: Color,
            backgroundBottom: Color,
            backgroundPrimary: Color,
            backgroundSecondary: Color,
            surfacePrimary: Color,
            surfaceSecondary: Color,
            interactivePrimary: Color,
            interactiveSecondary: Color,
            textPrimary: Color,
            textSecondary: Color,
            borderPrimary: Color,
            accentHighlight: Color,
            accentDestructive: Color,
            accentSuccess: Color,
            accentWarning: Color
        ) {
            self.backgroundTop = backgroundTop
            self.backgroundMiddle = backgroundMiddle
            self.backgroundBottom = backgroundBottom
            self.backgroundPrimary = backgroundPrimary
            self.backgroundSecondary = backgroundSecondary
            self.surfacePrimary = surfacePrimary
            self.surfaceSecondary = surfaceSecondary
            self.interactivePrimary = interactivePrimary
            self.interactiveSecondary = interactiveSecondary
            self.textPrimary = textPrimary
            self.textSecondary = textSecondary
            self.borderPrimary = borderPrimary
            self.accentHighlight = accentHighlight
            self.accentDestructive = accentDestructive
            self.accentSuccess = accentSuccess
            self.accentWarning = accentWarning
        }
    }

    // MARK: - Typography

    public enum Typography {
        // Logo Fonts
        case logo
        case logoLarge
        case logoSmall

        // Heading Fonts
        case heading1
        case heading2
        case heading3

        // Body Fonts
        case body
        case bodyLarge
        case bodySmall

        // Special Fonts
        case name

        public var font: Font {
            switch self {
            case .logo:
                return .custom("Underdog-Regular", size: 48)
            case .logoLarge:
                return .custom("Underdog-Regular", size: 72)
            case .logoSmall:
                return .custom("Underdog-Regular", size: 32)
            case .heading1:
                return .custom("RubikMarkerHatch-Regular", size: 32)
            case .heading2:
                return .custom("RubikDistressed-Regular", size: 24)
            case .heading3:
                return .custom("RubikGlitch-Regular", size: 20)
            case .body:
                return .custom("WDXLLubrifontTC-Regular", size: 16)
            case .bodyLarge:
                return .custom("WDXLLubrifontTC-Regular", size: 18)
            case .bodySmall:
                return .custom("WDXLLubrifontTC-Regular", size: 14)
            case .name:
                return .custom("Gabriela-Regular", size: 24)
            }
        }

        // Custom size variants
        public static func logo(size: CGFloat) -> Font {
            .custom("Underdog-Regular", size: size)
        }

        public static func logoLarge(size: CGFloat) -> Font {
            .custom("Underdog-Regular", size: size)
        }

        public static func heading1(size: CGFloat) -> Font {
            .custom("RubikMarkerHatch-Regular", size: size)
        }

        public static func body(size: CGFloat) -> Font {
            .custom("WDXLLubrifontTC-Regular", size: size)
        }

        public static func bodyLarge(size: CGFloat) -> Font {
            .custom("WDXLLubrifontTC-Regular", size: size)
        }

        public static func bodySmall(size: CGFloat) -> Font {
            .custom("WDXLLubrifontTC-Regular", size: size)
        }

        public static func heading2(size: CGFloat) -> Font {
            .custom("RubikDistressed-Regular", size: size)
        }

        public static func heading3(size: CGFloat) -> Font {
            .custom("RubikGlitch-Regular", size: size)
        }
    }

    // MARK: - Spacing

    public enum Spacing {
        case xs, sm, md, lg, xl, xxl

        public var value: CGFloat {
            switch self {
            case .xs: return 4
            case .sm: return 8
            case .md: return 16
            case .lg: return 24
            case .xl: return 32
            case .xxl: return 48
            }
        }
    }

    // MARK: - Border Radius

    public enum BorderRadius {
        case none, sm, md, lg, full

        public var value: CGFloat {
            switch self {
            case .none: return 0
            case .sm: return 4
            case .md: return 8
            case .lg: return 12
            case .full: return .infinity
            }
        }
    }

    // MARK: - Shadows

    public enum Shadow {
        case subtle, medium, strong

        @MainActor
        public var values: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            switch self {
            case .subtle:
                return (Theme.current.accentHighlight.opacity(0.3), 4, 0, 2)
            case .medium:
                return (Theme.current.accentHighlight.opacity(0.5), 8, 0, 4)
            case .strong:
                return (Theme.current.accentHighlight.opacity(0.8), 16, 0, 8)
            }
        }
    }

    // MARK: - Current Theme

    @MainActor
    public static var current: ThemeColors {
        ThemeManager.shared.current
    }

    // MARK: - Convenience Methods

    public static func text(_ style: Typography) -> some View {
        Text("").font(style.font)
    }

    public static func spacing(_ spacing: Spacing) -> CGFloat {
        spacing.value
    }

    @MainActor
    public static func shadow(_ shadow: Shadow) -> some ViewModifier {
        ShadowModifier(shadow: shadow)
    }
}

// MARK: - View Modifiers

private struct ShadowModifier: ViewModifier {
    let shadow: Theme.Shadow

    @MainActor
    func body(content: Content) -> some View {
        let values = shadow.values
        content.shadow(
            color: values.color,
            radius: values.radius,
            x: values.x,
            y: values.y
        )
    }
}

// MARK: - View Extensions

public extension View {
    @MainActor
    func themeText(_ style: Theme.Typography, color: Color? = nil) -> some View {
        self.font(style.font)
            .foregroundColor(color ?? Theme.current.textPrimary)
    }

    @MainActor
    func themeShadow(_ shadow: Theme.Shadow = .subtle) -> some View {
        self.modifier(Theme.shadow(shadow))
    }

    func themeBackground(_ color: Color) -> some View {
        self.background(color)
    }

    @MainActor
    func themeSurface(_ primary: Bool = true) -> some View {
        self.background(primary ? Theme.current.surfacePrimary : Theme.current.surfaceSecondary)
    }
}
