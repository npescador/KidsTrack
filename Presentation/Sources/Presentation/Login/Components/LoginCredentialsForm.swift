import SwiftUI

struct LoginCredentialsForm: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool

    var onTapForgotPassword: () -> Void
    var onSubmit: () -> Void

    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var body: some View {
        VStack(spacing: 20) {
            emailField
            passwordField
            submitButton
        }
        .frame(maxWidth: 420)
    }
}

private extension LoginCredentialsForm {
    var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LoginStrings.emailLabel)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

            TextField(
                "",
                text: $email,
                prompt: Text(LoginStrings.emailPlaceholder)
                    .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.emailAddress)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.kidsTrackSurface(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
            )
            .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            .accessibilityLabel(LoginStrings.emailLabel)
        }
    }

    var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(LoginStrings.passwordLabel)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

                Spacer()

                Button(action: onTapForgotPassword) {
                    Text(LoginStrings.forgotPasswordAction)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.kidsTrackPrimaryBlue)
            }

            ZStack(alignment: .trailing) {
                Group {
                    if isPasswordVisible {
                        TextField(
                            "",
                            text: $password,
                            prompt: Text(LoginStrings.passwordPlaceholder)
                                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
                        )
                    } else {
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text(LoginStrings.passwordPlaceholder)
                                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.kidsTrackSurface(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.kidsTrackBorder(for: colorScheme), lineWidth: 1)
                )
                .foregroundStyle(Color.kidsTrackTextPrimary(for: colorScheme))
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit(onSubmit)
                .accessibilityLabel(LoginStrings.passwordLabel)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.kidsTrackIconMuted(for: colorScheme))
                        .padding(.trailing, 16)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isPasswordVisible ? LoginStrings.hidePasswordLabel : LoginStrings.showPasswordLabel
                )
            }
        }
    }

    var submitButton: some View {
        Button(action: onSubmit) {
            Text(LoginStrings.loginButtonTitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(Color.kidsTrackPrimaryBlue)
                .foregroundStyle(Color.white)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .shadow(color: Color.kidsTrackPrimaryBlue.opacity(0.25), radius: 4, y: 2)
        .accessibilityHint(LoginStrings.loginButtonAccessibilityHint)
    }
}

#Preview("Login Credentials Form") {
    LoginCredentialsForm(
        email: .constant(""),
        password: .constant(""),
        isPasswordVisible: .constant(false),
        onTapForgotPassword: {},
        onSubmit: {}
    )
    .padding()
    .background(Color.kidsTrackBackground(for: .light))
}
