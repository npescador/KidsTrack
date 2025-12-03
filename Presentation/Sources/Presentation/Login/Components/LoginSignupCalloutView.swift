import SwiftUI

struct LoginSignupCalloutView: View {
    let action: () -> Void
    var isDisabled: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            Text("login.signup.prompt".localizedText())
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

            Button(action: action) {
                Text("login.signup.cta".localizedText())
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .underline()
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .foregroundStyle(Color.kidsTrackPrimaryBlue)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Login Signup Callout") {
    LoginSignupCalloutView(action: {}, isDisabled: false)
        .padding()
        .background(Color.kidsTrackBackground(for: .light))
}
