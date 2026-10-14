import SwiftUI

extension View {
    /// Places a full-bleed, darkened background image behind the view.
    ///
    /// The background never takes part in the view's layout: it fills whatever space the view
    /// occupies, extends under every safe area (including the keyboard), and is clipped to it,
    /// so it stays put when the content resizes.
    func screenBackground(_ image: ImageResource) -> some View {
        background {
            ScreenBackground(image: image)
                .ignoresSafeArea()
        }
    }
}

private struct ScreenBackground: View {
    let image: ImageResource
    var overlayOpacity = 0.7

    var body: some View {
        // `Color.clear` takes exactly the proposed size; the image fills it from an overlay
        // and is clipped, so its aspect-fill size can never leak into layout.
        Color.clear
            .overlay {
                Image(image)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .overlay { tint }
            .accessibilityHidden(true)
    }

    private var tint: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Theme.current.backgroundTop.opacity(overlayOpacity * 0.8),
                        Theme.current.backgroundMiddle.opacity(overlayOpacity * 0.9),
                        Theme.current.backgroundBottom.opacity(overlayOpacity * 0.9),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                LinearGradient(
                    colors: [
                        Theme.current.accentHighlight.opacity(overlayOpacity * 0.1),
                        .clear,
                        Theme.current.accentWarning.opacity(overlayOpacity * 0.05),
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
            .blendMode(.multiply)

            RadialGradient(
                colors: [.clear, Theme.current.backgroundPrimary.opacity(overlayOpacity * 0.3)],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
        }
    }
}

#Preview {
    Text(verbatim: "Alias")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground(.homeScreenBg)
}
