import SwiftUI

extension View {
    /// The app's look for single-line text input: body font, dark rounded fill, no autocorrection.
    func themedTextField(fontSize: CGFloat = 16) -> some View {
        font(Theme.Typography.body(size: fontSize))
            .foregroundStyle(Theme.current.textPrimary)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(12)
            .background(.black.opacity(0.2), in: .rect(cornerRadius: 10))
    }
}
