import SwiftUI

struct DarkBackgroundView: View {
    let backgroundImage: String
    let overlayOpacity: Double

    init(
        backgroundImage: String,
        overlayOpacity: Double = 0.7
    ) {
        self.backgroundImage = backgroundImage
        self.overlayOpacity = overlayOpacity
    }

    var body: some View {
        ZStack {
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Mystical multi-layered gradient overlay using theme colors
            ZStack {
                // Primary gradient - deep atmospheric colors
                LinearGradient(
                    gradient: Gradient(colors: [
                        Theme.current.backgroundTop.opacity(
                            overlayOpacity * 0.8
                        ),
                        Theme.current.backgroundMiddle.opacity(
                            overlayOpacity * 0.9
                        ),
                        Theme.current.backgroundBottom.opacity(
                            overlayOpacity * 0.9
                        ),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Accent gradient for mystical effect
                LinearGradient(
                    gradient: Gradient(colors: [
                        Theme.current.accentHighlight.opacity(
                            overlayOpacity * 0.1
                        ),
                        .clear,
                        Theme.current.accentWarning.opacity(
                            overlayOpacity * 0.05
                        ),
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
            .ignoresSafeArea()
            .blendMode(.multiply)

            // Subtle vignette effect
            RadialGradient(
                gradient: Gradient(colors: [
                    .clear,
                    Theme.current.backgroundPrimary.opacity(
                        overlayOpacity * 0.3
                    ),
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        DarkBackgroundView(backgroundImage: "HomeScreenBg")
        Text("Test Content")
            .themeText(.heading1)
            .themeShadow(.medium)
    }
}
