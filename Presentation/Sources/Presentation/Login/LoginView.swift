import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        ZStack {
            Color.kidsTrackBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    LoginHeader()

                    LoginCredentialsForm(
                        email: $email,
                        password: $password,
                        isPasswordVisible: $isPasswordVisible,
                        onTapForgotPassword: handleForgotPassword,
                        onSubmit: handleLogin
                    )

                    LoginSeparator()

                    LoginSocialButton(
                        title: LoginStrings.googleButtonTitle,
                        accessibilityHint: LoginStrings.googleButtonAccessibilityHint,
                        action: handleGoogleLogin
                    )

                    LoginSignupCallout(action: handleSignup)
                }
                .frame(maxWidth: 420)
                .padding(.horizontal, 24)
                .padding(.vertical, 48)
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 16)
        }
        .font(.system(.body, design: .rounded))
    }
}

private extension LoginView {
    func handleForgotPassword() {
        // TODO: Navigate to password recovery flow.
    }

    func handleLogin() {
        // TODO: Hook into authentication use case.
    }

    func handleGoogleLogin() {
        // TODO: Kick off Google sign-in.
    }

    func handleSignup() {
        // TODO: Navigate to the sign-up experience.
    }
}

#Preview("Login • Light", traits: .fixedLayout(width: 430, height: 932)) {
    LoginView()
        .preferredColorScheme(.light)
}

#Preview("Login • Dark", traits: .fixedLayout(width: 430, height: 932)) {
    LoginView()
        .preferredColorScheme(.dark)
}
