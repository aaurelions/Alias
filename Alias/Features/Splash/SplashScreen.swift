import SwiftUI

/// Launch animation: the letters pop in, then the logo rises and the screen fades out.
struct SplashScreen: View {
    let onFinished: () -> Void

    @State private var letterScales = Array(repeating: CGFloat.zero, count: Self.title.count)
    @State private var isLeaving = false

    private static let title = Array("Alias")
    private static let displayDuration = Duration.seconds(3)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Self.title.indices, id: \.self) { index in
                OutlinedLetter(letter: Self.title[index])
                    .opacity(letterScales[index] > 0 ? 0.5 : 0)
                    .scaleEffect(x: letterScales[index], y: letterScales[index] * 2)
            }
        }
        .rotationEffect(.degrees(3))
        .padding(.bottom, 40)
        // Leaving moves the logo from the bottom edge to the middle of the screen.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isLeaving ? .center : .bottom)
        .screenBackground(.splashScreenBg)
        .opacity(isLeaving ? 0 : 1)
        .accessibilityHidden(true)
        .task { await play() }
    }

    private func play() async {
        let start = ContinuousClock.now

        for index in Self.title.indices {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                letterScales[index] = 1.2
            } completion: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    letterScales[index] = 1
                }
            }
            guard await (try? Task.sleep(for: .milliseconds(150))) != nil else { return }
        }

        guard await (try? Task.sleep(until: start + Self.displayDuration)) != nil else { return }
        withAnimation(.easeInOut(duration: 1)) {
            isLeaving = true
        } completion: {
            onFinished()
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
    SplashScreen {}
}
