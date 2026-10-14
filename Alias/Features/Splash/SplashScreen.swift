import SwiftUI

struct SplashScreen: View {
    let logoOffset: CGFloat

    @State private var letterScales = Array(repeating: CGFloat.zero, count: Self.title.count)

    private static let title = Array("Alias")

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 0) {
                ForEach(Self.title.indices, id: \.self) { index in
                    OutlinedLetter(letter: Self.title[index])
                        .opacity(letterScales[index] > 0 ? 0.5 : 0)
                        .scaleEffect(x: letterScales[index], y: letterScales[index] * 2)
                }
            }
            .rotationEffect(.degrees(3))
            .padding(.bottom, 40)
            .offset(y: logoOffset)
        }
        .frame(maxWidth: .infinity)
        .background(DarkBackgroundView(backgroundImage: "SplashScreenBg"))
        .task {
            for index in Self.title.indices {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    letterScales[index] = 1.2
                } completion: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        letterScales[index] = 1
                    }
                }
                try? await Task.sleep(for: .milliseconds(150))
            }
        }
    }
}

struct OutlinedLetter: View {
    let letter: Character
    var size: CGFloat = 72

    private let strokeWidth: CGFloat = 1

    var body: some View {
        Text(String(letter))
            .font(Theme.Typography.logo(size: size))
            .foregroundStyle(Theme.current.textPrimary)
            .background {
                ZStack {
                    Text(String(letter)).offset(x: strokeWidth, y: strokeWidth)
                    Text(String(letter)).offset(x: -strokeWidth, y: strokeWidth)
                    Text(String(letter)).offset(x: -strokeWidth, y: -strokeWidth)
                }
                .font(Theme.Typography.logo(size: size))
                .foregroundStyle(Color.black.opacity(0.9))
            }
    }
}

#Preview {
    SplashScreen(logoOffset: 0)
}
