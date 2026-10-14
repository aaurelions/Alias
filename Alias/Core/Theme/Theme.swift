import SwiftUI

public struct Theme {
    // MARK: - Colors

    public struct Colors {
        public let backgroundTop: Color
        public let backgroundMiddle: Color
        public let backgroundBottom: Color

        public let backgroundPrimary: Color
        public let backgroundSecondary: Color

        public let surfacePrimary: Color
        public let surfaceSecondary: Color

        public let interactivePrimary: Color
        public let interactiveSecondary: Color

        public let textPrimary: Color
        public let textSecondary: Color

        public let borderPrimary: Color

        public let accentHighlight: Color
        public let accentDestructive: Color
        public let accentSuccess: Color
        public let accentWarning: Color

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
        case logo
        case logoLarge
        case logoSmall

        case heading1
        case heading2
        case heading3

        case body
        case bodyLarge
        case bodySmall

        case name

        public var font: Font {
            switch self {
            case .logo:
                .custom("Underdog-Regular", size: 48)
            case .logoLarge:
                .custom("Underdog-Regular", size: 72)
            case .logoSmall:
                .custom("Underdog-Regular", size: 32)
            case .heading1:
                .custom("RubikMarkerHatch-Regular", size: 32)
            case .heading2:
                .custom("RubikDistressed-Regular", size: 24)
            case .heading3:
                .custom("RubikGlitch-Regular", size: 20)
            case .body:
                .custom("WDXLLubrifontTC-Regular", size: 16)
            case .bodyLarge:
                .custom("WDXLLubrifontTC-Regular", size: 18)
            case .bodySmall:
                .custom("WDXLLubrifontTC-Regular", size: 14)
            case .name:
                .custom("Gabriela-Regular", size: 24)
            }
        }

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
            case .xs: 4
            case .sm: 8
            case .md: 16
            case .lg: 24
            case .xl: 32
            case .xxl: 48
            }
        }
    }

    // MARK: - Border Radius

    public enum BorderRadius {
        case none, sm, md, lg, full

        public var value: CGFloat {
            switch self {
            case .none: 0
            case .sm: 4
            case .md: 8
            case .lg: 12
            case .full: .infinity
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
                (Theme.current.accentHighlight.opacity(0.3), 4, 0, 2)
            case .medium:
                (Theme.current.accentHighlight.opacity(0.5), 8, 0, 4)
            case .strong:
                (Theme.current.accentHighlight.opacity(0.8), 16, 0, 8)
            }
        }
    }

    // MARK: - Current Theme

    static let current = ThemeColors.dark

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
