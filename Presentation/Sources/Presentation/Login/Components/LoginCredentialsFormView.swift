import SwiftUI

struct LoginCredentialsFormView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    var isLoading: Bool = false

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

private extension LoginCredentialsFormView {
    var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("login.form.email.label".localized())
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

            TextField(
                "",
                text: $email,
                prompt: Text("login.form.email.placeholder".localized())
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
            .accessibilityLabel(Text("login.form.email.label".localized()))
        }
    }

    var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("login.form.password.label".localized())
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))

                Spacer()

                Button(action: onTapForgotPassword) {
                    Text("login.form.password.forgot".localized())
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
                            prompt: Text("login.form.password.placeholder".localized())
                                .foregroundStyle(Color.kidsTrackTextSecondary(for: colorScheme))
                        )
                    } else {
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text("login.form.password.placeholder".localized())
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
                .accessibilityLabel(Text("login.form.password.label".localized()))

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
                    Text(
                        isPasswordVisible
                            ? "login.form.password.hide".localized()
                            : "login.form.password.show".localized()
                    )
                )
            }
        }
    }

    var submitButton: some View {
        Button(action: onSubmit) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("login.form.primary.cta".localized())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background(Color.kidsTrackPrimaryBlue)
            .foregroundStyle(Color.white)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .shadow(color: Color.kidsTrackPrimaryBlue.opacity(0.25), radius: 4, y: 2)
        .accessibilityHint(Text("login.form.primary.cta.hint".localized()))
    }
}

#Preview("Login Credentials Form") {
    LoginCredentialsFormView(
        email: .constant(""),
        password: .constant(""),
        isPasswordVisible: .constant(false),
        isLoading: false,
        onTapForgotPassword: {},
        onSubmit: {}
    )
    .padding()
    .background(Color.kidsTrackBackground(for: .light))
}
