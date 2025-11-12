import SwiftUI

struct LoginSignupCallout: View {
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            Text(LoginStrings.signupPrompt)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

            Button(action: action) {
                Text(LoginStrings.signupAction)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .underline()
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.kidsTrackPrimaryBlue)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Login Signup Callout") {
    LoginSignupCallout(action: {})
        .padding()
        .background(Color.kidsTrackBackground(for: .light))
}
