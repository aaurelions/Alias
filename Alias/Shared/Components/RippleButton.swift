import SwiftUI

/// Primary call-to-action button with an outward ripple on tap.
struct RippleButton: View {
    let title: String
    var systemImage: String?
    var fontSize: CGFloat = 28
    var fillsWidth = false
    var isEnabled = true
    let action: () -> Void

    @State private var isRippling = false

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: AnimationDefaults.rippleDuration)) {
                isRippling = true
            } completion: {
                isRippling = false
            }
            action()
        } label: {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                }
                Text(title)
                    .font(Theme.Typography.heading1(size: fontSize))
            }
            .foregroundStyle(Theme.current.interactivePrimary)
            .opacity(isEnabled ? 1 : 0.45)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .frame(height: 60)
        .background(Theme.current.surfacePrimary.opacity(0.2), in: .rect(cornerRadius: 10))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.current.borderPrimary.opacity(0.1), lineWidth: 20)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.current.borderPrimary.opacity(isRippling ? 0 : 0.1), lineWidth: isRippling ? 60 : 20)
                .scaleEffect(isRippling ? 2.5 : 1)
                .opacity(isRippling ? 0 : 1)
        }
        .rotationEffect(.degrees(-3))
    }
}

#Preview {
    VStack(spacing: 40) {
        RippleButton(title: "Start Game") {}
        RippleButton(title: "Disabled", isEnabled: false) {}
        RippleButton(title: "Home", systemImage: "house.fill", fontSize: 22, fillsWidth: true) {}
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.current.backgroundPrimary)
}
