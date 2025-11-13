import SwiftUI

struct LoginSignupCalloutView: View {
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            Text("login.signup.prompt".localized())
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

            Button(action: action) {
                Text("login.signup.cta".localized())
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
    LoginSignupCalloutView(action: {})
        .padding()
        .background(Color.kidsTrackBackground(for: .light))
}
