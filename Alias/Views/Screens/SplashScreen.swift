import SwiftUI

struct SplashScreen: View {
    let logoOffset: CGFloat
    let logoScale: CGFloat

    let strokeColor = Color.black.opacity(0.9)
    let strokeWidth: CGFloat = 1

    @State private var letterScales: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var showLetters = false

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 0) {
                ForEach(Array("Alias".enumerated()), id: \.offset) { index, letter in
                    Text(String(letter))
                        .font(Theme.Typography.logo(size: 72))
                        .foregroundColor(Theme.current.textPrimary)
                        .background(
                            ZStack {
                                Text(String(letter)).offset(x:  strokeWidth, y:  strokeWidth)
                                Text(String(letter)).offset(x: -strokeWidth, y:  strokeWidth)
                                Text(String(letter)).offset(x: -strokeWidth, y: -strokeWidth)
                            }
                            .font(Theme.Typography.logo(size: 72))
                            .foregroundColor(strokeColor)
                        )
                        .opacity(showLetters ? 0.5 : 0)
                        .scaleEffect(x: letterScales[index] * logoScale, y: letterScales[index] * logoScale * 2)
                }
            }
            .rotationEffect(.degrees(3))
            .padding(.bottom, 40)
            .offset(y: logoOffset)
        }
        .background(DarkBackgroundView(backgroundImage: "SplashScreenBg"))
        .onAppear {
            // Staggered letter appearance animation (0 to 1.2 to 1.0)
            for index in 0..<5 {
                let delay = Double(index) * 0.15

                // First: scale from 0 to 1.2
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        letterScales[index] = 1.2
                        showLetters = true
                    }
                }

                // Then: scale from 1.2 to 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        letterScales[index] = 1.0
                    }
                }
            }
        }
    }
}

#Preview("Centered Logo") {
    SplashScreen(logoOffset: 0, logoScale: 1.0)
}

#Preview("Logo Offset Up") {
    SplashScreen(logoOffset: -100, logoScale: 1.0)
}

#Preview("Logo Scaled Large") {
    SplashScreen(logoOffset: 0, logoScale: 1.5)
}

#Preview("Logo Offset Down & Small") {
    SplashScreen(logoOffset: 100, logoScale: 0.7)
}
