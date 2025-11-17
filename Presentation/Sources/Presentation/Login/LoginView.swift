import SwiftUI

/// Login screen binding directly to `LoginViewModel` so it can react to Firebase-auth backed states.
public struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var isPasswordVisible = false
    @State private var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.kidsTrackBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    LoginHeaderView()

                    if let banner = viewModel.banner {
                        LoginStatusBannerView(banner: banner)
                            .transition(.opacity)
                    }

                    LoginCredentialsFormView(
                        email: $viewModel.email,
                        password: $viewModel.password,
                        isPasswordVisible: $isPasswordVisible,
                        isLoading: viewModel.isLoading,
                        onTapForgotPassword: handleForgotPassword,
                        onSubmit: handleLogin
                    )

                    if viewModel.isAuthenticated, let email = viewModel.authenticatedEmail {
                        authenticatedCard(email: email, logoutAction: viewModel.logout)
                    }

                    LoginSeparatorView()

                    LoginSocialButtonView(
                        title: "login.social.google.title".localized(),
                        accessibilityHint: "login.social.google.hint".localized(),
                        action: handleGoogleLogin
                    )

                    LoginSignupCalloutView(
                        action: handleSignup,
                        isDisabled: viewModel.isLoading
                    )
                }
                .frame(maxWidth: 420)
                .padding(.horizontal, 24)
                .padding(.vertical, 48)
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 16)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                    .accessibilityLabel(Text("Signing in…"))
            }
        }
        .font(.system(.body, design: .rounded))
    }
}

private extension LoginView {
    func handleForgotPassword() {
        viewModel.sendPasswordReset()
    }

    func handleLogin() {
        viewModel.login()
    }

    func handleGoogleLogin() {
        // Kick off Google sign-in. Pending future implementation.
    }

    func handleSignup() {
        viewModel.register()
    }

    @ViewBuilder
    func authenticatedCard(email: String, logoutAction: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Text("Signed in as \(email)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: logoutAction) {
                Text("Logout")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .background(Color.kidsTrackSurface(for: colorScheme))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.kidsTrackSurface(for: colorScheme))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Login • Light", traits: .fixedLayout(width: 430, height: 932)) {
    LoginView(viewModel: .preview())
        .preferredColorScheme(.light)
}

#Preview("Login • Dark", traits: .fixedLayout(width: 430, height: 932)) {
    LoginView(viewModel: .preview())
        .preferredColorScheme(.dark)
}
