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

            ZStack {
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
    DarkBackgroundView(backgroundImage: "HomeScreenBg")
}
