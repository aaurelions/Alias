import Combine
import SwiftUI

// MARK: - Primary Button

/// Standard primary button with full-width layout
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(Theme.Typography.bodyLarge(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.current.backgroundPrimary)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: Theme.current.backgroundPrimary
                            )
                        )
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Theme.current.interactivePrimary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Secondary Button

/// Standard secondary button with outline style
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.bodyLarge(size: 18))
                .fontWeight(.bold)
                .foregroundColor(Theme.current.textPrimary.opacity(0.7))
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Theme.current.surfaceSecondary.opacity(0.5))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Icon Button

/// Circular button with icon only
struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var backgroundColor: Color = Theme.current.surfaceSecondary.opacity(0.3)
    var foregroundColor: Color = Theme.current.textPrimary

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stepper Buttons

/// Plus button for incrementing values
struct IncrementButton: View {
    let action: () -> Void
    var color: Color = Theme.current.accentSuccess.opacity(0.8)
    var size: CGFloat = 36

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.current.accentSuccess.opacity(0.2))
                    .frame(width: size, height: size)
                Image(systemName: "plus")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Minus button for decrementing values
struct DecrementButton: View {
    let action: () -> Void
    var color: Color = Theme.current.accentDestructive.opacity(0.8)
    var size: CGFloat = 36

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.current.accentDestructive.opacity(0.2))
                    .frame(width: size, height: size)
                Image(systemName: "minus")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Option Button

/// Selectable option button for segmented controls
struct OptionButton: View {
    let option: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(option)
                .font(Theme.Typography.body(size: 14))
                .foregroundColor(Theme.current.textSecondary)
                .fontWeight(selected ? .bold : .regular)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
                .background(buttonBackground)
                .scaleEffect(selected ? 1.1 : 1.0)
                .animation(
                    .spring(response: 0.2, dampingFraction: 0.8),
                    value: selected
                )
        }
        .buttonStyle(.plain)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: UIConstants.defaultCornerRadius)
            .fill(
                selected
                    ? Theme.current.interactivePrimary.opacity(0.6)
                    : Theme.current.surfacePrimary.opacity(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: UIConstants.defaultCornerRadius)
                    .stroke(
                        selected
                            ? Theme.current.interactivePrimary
                            : Theme.current.borderPrimary,
                        lineWidth: selected ? 2 : 1
                    )
            )
    }
}

// MARK: - Text Button

/// Simple text-only button
struct TextButton: View {
    let title: String
    let action: () -> Void
    var color: Color = Theme.current.interactivePrimary

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.body(size: 16))
                .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Secondary Button") {
    VStack(spacing: 20) {
        SecondaryButton(title: "Cancel", action: {})
        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Icon Button") {
    VStack(spacing: 20) {
        IconButton(icon: "gear", action: {})
        IconButton(icon: "xmark", action: {}, size: 50, iconSize: 24)
        IconButton(
            icon: "heart.fill",
            action: {},
            backgroundColor: Theme.current.accentDestructive.opacity(0.3),
            foregroundColor: Theme.current.accentDestructive
        )
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Stepper Buttons") {
    HStack(spacing: 40) {
        DecrementButton(action: {})
        IncrementButton(action: {})
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Option Buttons") {
    HStack(spacing: 12) {
        OptionButton(option: "30s", selected: false, action: {})
        OptionButton(option: "60s", selected: true, action: {})
        OptionButton(option: "90s", selected: false, action: {})
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Text Button") {
    VStack(spacing: 20) {
        TextButton(title: "Learn More", action: {})
        TextButton(
            title: "Delete",
            action: {},
            color: Theme.current.accentDestructive
        )
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

// MARK: - Main Preview View

struct CozyMysticalButtonsViewL: View {
    // Applying the new theme and your custom fonts
    @StateObject private var themeManager = ThemeManager.shared

    struct Theme {
        static var current: ThemeColors { ThemeManager.shared.current }

        struct Typography {
            public static func logo(size: CGFloat) -> Font {
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
            public static func heading2(size: CGFloat) -> Font {
                .custom("RubikDistressed-Regular", size: size)
            }
        }
    }

    var body: some View {
        ZStack {
            DustParticleBackgroundL()

            ScrollView {
                VStack(spacing: 24) {
                    GlowingMossButton("Enter the Woods")
                    FireflyPathButton("Follow the Light")
                    RunicEarthButton("Awaken")
                    WhisperingWindButton("Listen")
                    SunDappledLeafButton("Bask")
                    BreathingCreatureButton("Rest Here")
                    EnchantedWaterButton("Reflect")
                    GlimmeringGeodeButton("Look Within")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
        }
        // Set the background to a gradient using the new theme colors
        .background(
            LinearGradient(
                colors: [
                    Theme.current.backgroundTop, Theme.current.backgroundMiddle,
                    Theme.current.backgroundBottom,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

// MARK: - Enhanced Background Dust Particle Effect
struct DustParticleBackgroundL: View {
    struct Particle: Identifiable {
        let id = UUID(), initialPosition: CGPoint, vector: CGVector
        let opacity: Double, scale: CGFloat
    }
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for particle in particles {
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        let currentPos = CGPoint(
                            x: particle.initialPosition.x + particle.vector.dx
                                * CGFloat(time),
                            y: particle.initialPosition.y + particle.vector.dy
                                * CGFloat(time)
                        )
                        let wrappedX =
                            (currentPos.x + 50).truncatingRemainder(
                                dividingBy: size.width + 100
                            ) - 50
                        let wrappedY =
                            (currentPos.y + 50).truncatingRemainder(
                                dividingBy: size.height + 100
                            ) - 50
                        var particleContext = context
                        particleContext.opacity = particle.opacity
                        let rect = CGRect(
                            origin: .zero,
                            size: CGSize(
                                width: 8 * particle.scale,
                                height: 8 * particle.scale
                            )
                        )
                        particleContext.fill(
                            Path(ellipseIn: rect),
                            with: .color(
                                CozyMysticalButtonsViewL.Theme.current
                                    .interactivePrimary.opacity(0.5)
                            )
                        )
                        particleContext.translateBy(x: wrappedX, y: wrappedY)
                    }
                }
            }
            .onAppear {
                for _ in 0..<70 {
                    particles.append(createParticle(in: geo.size))
                }
            }
        }
    }

    func createParticle(in size: CGSize) -> Particle {
        Particle(
            initialPosition: CGPoint(
                x: .random(in: -50...size.width + 50),
                y: .random(in: -50...size.height + 50)
            ),
            vector: CGVector(
                dx: .random(in: -15...15),
                dy: .random(in: -15...15)
            ),
            opacity: .random(in: 0.05...0.3),
            scale: .random(in: 0.4...1.0)
        )
    }
}

// MARK: - 1. Glowing Moss Button
struct GlowingMossButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var glowPosition: UnitPoint = .init(x: -0.5, y: -0.5)

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.heading2(size: 24))
                .foregroundColor(theme.current.textPrimary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        theme.current.surfacePrimary
                        // Click Flash
                        theme.current.interactivePrimary.opacity(
                            isPressed ? 0.3 : 0
                        )
                        // Standby Glow
                        RadialGradient(
                            colors: [
                                theme.current.interactivePrimary.opacity(0.2),
                                .clear,
                            ],
                            center: glowPosition,
                            startRadius: 0,
                            endRadius: 150
                        )
                        .opacity(isPressed ? 0 : 1)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 5.0).repeatForever(autoreverses: true)
            ) { glowPosition = .init(x: 1.5, y: 1.5) }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - 2. Firefly Path Button
struct FireflyPathButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var fireflyPos: CGFloat = 0

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.bodyLarge(size: 24))
                .foregroundColor(theme.current.textPrimary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.backgroundPrimary)
                .overlay(
                    FireflyPathShape().trim(
                        from: fireflyPos - 0.1,
                        to: fireflyPos
                    )
                    .stroke(
                        theme.current.interactivePrimary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .shadow(color: theme.current.interactivePrimary, radius: 8)
                    .opacity(isPressed ? 0.5 : 1.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4.0).repeatForever(autoreverses: true)
            ) { fireflyPos = 1.1 }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    struct FireflyPathShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path {
                $0.move(to: CGPoint(x: rect.minX, y: rect.height * 0.8))
                $0.addQuadCurve(
                    to: CGPoint(x: rect.maxX, y: rect.height * 0.2),
                    control: CGPoint(x: rect.midX, y: rect.height * 0.1)
                )
            }
        }
    }
}

// MARK: - 3. Runic Earth Button
struct RunicEarthButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var runeOpacity: Double = 0.2

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.heading1(size: 26))
                .foregroundColor(theme.current.textSecondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.backgroundSecondary)
                .overlay(
                    Image(systemName: "triangle")
                        .font(.system(size: 30))
                        .foregroundColor(theme.current.interactivePrimary)
                        .opacity(isPressed ? 1.0 : runeOpacity)
                        .shadow(
                            color: theme.current.interactivePrimary,
                            radius: isPressed ? 20 : 5
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.5).repeatForever(autoreverses: true)
            ) { runeOpacity = 0.5 }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - 4. Whispering Wind Button
struct WhisperingWindButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var mistOffset: CGFloat = -200

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.body(size: 24))
                .foregroundColor(theme.current.textPrimary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.surfaceSecondary)
                .mask(
                    // Reveal on click
                    RadialGradient(
                        colors: isPressed ? [.clear, .black] : [.black],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .overlay(
                    // Standby Mist
                    MistCloud().offset(x: mistOffset).opacity(isPressed ? 0 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .linear(duration: 6.0).repeatForever(autoreverses: false)
            ) { mistOffset = 200 }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    struct MistCloud: View {
        var body: some View {
            Image(systemName: "cloud.fill").resizable().scaledToFit().frame(
                width: 400
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.white.opacity(0.15), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// MARK: - 5. Sun-Dappled Leaf Button
struct SunDappledLeafButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var sunSpotPos: UnitPoint = .topLeading

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.bodyLarge(size: 24))
                .foregroundColor(theme.current.textPrimary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.surfacePrimary)
                .overlay(
                    // Standby sun spot
                    Circle().fill(theme.current.interactivePrimary.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .blur(radius: 30)
                        .position(x: sunSpotPos.x, y: sunSpotPos.y)
                )
                .overlay(
                    // Click flare
                    theme.current.interactivePrimary.opacity(
                        isPressed ? 0.2 : 0
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6.0).repeatForever(autoreverses: true)
            ) { sunSpotPos = .bottomTrailing }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - 6. Breathing Creature Button
struct BreathingCreatureButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var isBreathing = false

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.heading2(size: 24))
                .foregroundColor(theme.current.textSecondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(
                    y: isPressed ? 0.95 : (isBreathing ? 1.02 : 1.0),
                    anchor: .center
                )
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.5),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.5).repeatForever(autoreverses: true)
            ) { isBreathing.toggle() }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - 7. Enchanted Water Button
struct EnchantedWaterButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var waveProgress: CGFloat = 0

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.body(size: 24))
                .foregroundColor(theme.current.textPrimary.opacity(0.8))
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.backgroundPrimary)
                .overlay(
                    // Standby waves
                    WaveShape(progress: waveProgress)
                        .fill(
                            theme.current.interactivePrimary.opacity(
                                isPressed ? 0.3 : 0.1
                            )
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .linear(duration: 3.0).repeatForever(autoreverses: false)
            ) { waveProgress = 1.0 }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    struct WaveShape: Shape {
        var progress: CGFloat
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                for x in stride(from: 0, to: rect.width, by: 5) {
                    let y =
                        rect.midY + sin((x / 50) + (progress * .pi * 2)) * 10
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.closeSubpath()
            }
        }
    }
}

// MARK: - 8. Glimmering Geode Button
struct GlimmeringGeodeButton: View {
    let text: LocalizedStringKey
    @State private var isPressed = false
    @State private var glimmerOpacity: Double = 0.0

    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        let theme = CozyMysticalButtonsViewL.Theme.self
        Button(action: {}) {
            Text(text)
                .font(theme.Typography.logo(size: 26))
                .foregroundColor(theme.current.textPrimary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.current.backgroundSecondary)
                .overlay(
                    // Click flash
                    theme.current.interactivePrimary.opacity(
                        isPressed ? 0.2 : 0
                    )
                )
                .overlay(alignment: .leading) {
                    // Standby glimmer
                    Circle().fill(theme.current.interactivePrimary)
                        .frame(width: 10, height: 10).blur(radius: 5)
                        .opacity(glimmerOpacity)
                        .padding(.leading, 40)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2).repeatForever().delay(2.0))
            { glimmerOpacity = 0.5 }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    CozyMysticalButtonsViewL()
}
