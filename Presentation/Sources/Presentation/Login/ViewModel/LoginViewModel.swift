import Domain
import Foundation
import Observation
import Shared
import UIKit

@MainActor
@Observable
public final class LoginViewModel {
    public struct Banner: Equatable {
        public enum Style {
            case success
            case error
            case info
        }

        public let style: Style
        public let message: String

        public init(style: Style, message: String) {
            self.style = style
            self.message = message
        }
    }

    public var email = ""
    public var password = ""
    public var isLoading = false
    public var banner: Banner?
    public var authState: AuthState = .unauthenticated

    public var isLoginFormValid: Bool {
        isValidEmail(email) && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isRegisterFormValid: Bool {
        isValidEmail(email) && password.count >= minimumPasswordLength
    }

    public var isPrimaryActionDisabled: Bool {
        !isLoginFormValid
    }

    public var isRegisterDisabled: Bool {
        isLoading || !isRegisterFormValid
    }

    private let minimumPasswordLength = 6
    private let loginUseCase: LoginUseCase
    private let registerUseCase: RegisterUseCase
    private let googleSignInUseCase: SignInWithGoogleUseCase
    private let googleSignInHandler: GoogleSignInHandling
    private let passwordResetUseCase: SendPasswordResetUseCase
    private let logoutUseCase: LogoutUseCase
    private let observeAuthStateUseCase: ObserveAuthStateUseCase

    @ObservationIgnored
    private var authObservationTask: Task<Void, Never>?

    public init(
        loginUseCase: LoginUseCase,
        registerUseCase: RegisterUseCase,
        googleSignInUseCase: SignInWithGoogleUseCase,
        googleSignInHandler: GoogleSignInHandling,
        passwordResetUseCase: SendPasswordResetUseCase,
        logoutUseCase: LogoutUseCase,
        observeAuthStateUseCase: ObserveAuthStateUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
        self.googleSignInUseCase = googleSignInUseCase
        self.googleSignInHandler = googleSignInHandler
        self.passwordResetUseCase = passwordResetUseCase
        self.logoutUseCase = logoutUseCase
        self.observeAuthStateUseCase = observeAuthStateUseCase

        observeAuthState()
    }

    deinit {
        authObservationTask?.cancel()
    }

    public var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }

    public var authenticatedEmail: String? {
        if case let .authenticated(user) = authState {
            return user.email
        }
        return nil
    }

    public func login() {
        guard validateCredentials(for: .login) else { return }
        let email = self.email
        let password = self.password
        let loginUseCase = self.loginUseCase
        submit(
            successMessage: "Welcome back!",
            operation: {
                try await loginUseCase.execute(email: email, password: password)
            }
        )
    }

    public func register() {
        guard validateCredentials(for: .register) else { return }
        let email = self.email
        let password = self.password
        let registerUseCase = self.registerUseCase
        submit(
            successMessage: "Account created successfully.",
            operation: {
                try await registerUseCase.execute(email: email, password: password)
            }
        )
    }

    public func signInWithGoogle(presentingViewController: UIViewController) {
        guard !isLoading else { return }
        isLoading = true
        banner = nil

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let tokens = try await googleSignInHandler.signIn(presentingViewController: presentingViewController)
                let user = try await googleSignInUseCase.execute(
                    idToken: tokens.idToken,
                    accessToken: tokens.accessToken
                )
                await MainActor.run {
                    self.handleSuccess(message: "Signed in with Google.", user: user)
                }
            } catch {
                await MainActor.run {
                    self.handleFailure(error)
                }
            }
        }
    }

    public func sendPasswordReset() {
        guard validateEmailOnly() else { return }
        let email = self.email
        let passwordResetUseCase = self.passwordResetUseCase
        submit(
            successMessage: "Password reset email sent.",
            operation: {
                try await passwordResetUseCase.execute(email: email)
                return nil as AuthUser?
            }
        )
    }

    public func logout() {
        guard isAuthenticated else {
            banner = Banner(style: .info, message: "No authenticated user to sign out.")
            return
        }

        let logoutUseCase = self.logoutUseCase
        submit(
            successMessage: "Signed out.",
            operation: {
                try await logoutUseCase.execute()
                return nil as AuthUser?
            }
        )
    }
}

private extension LoginViewModel {
    enum AuthAction {
        case login
        case register
    }

    func submit(
        successMessage: String,
        operation: @escaping () async throws -> AuthUser?
    ) {
        guard !isLoading else { return }
        isLoading = true
        banner = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await operation()
                self.handleSuccess(
                    message: successMessage,
                    user: user
                )
            } catch {
                self.handleFailure(error)
            }
        }
    }

    func validateEmailOnly() -> Bool {
        guard isValidEmail(email) else {
            banner = Banner(style: .error, message: "Enter a valid email address.")
            return false
        }
        return true
    }

    func validateCredentials(for action: AuthAction) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(trimmedEmail) else {
            banner = Banner(style: .error, message: "Enter a valid email address.")
            return false
        }

        guard !trimmedPassword.isEmpty else {
            banner = Banner(style: .error, message: "Password is required.")
            return false
        }

        if action == .register, trimmedPassword.count < minimumPasswordLength {
            banner = Banner(
                style: .error,
                message: "Password must be at least \(minimumPasswordLength) characters."
            )
            return false
        }

        return true
    }

    @MainActor
    func handleSuccess(message: String, user: AuthUser?) {
        if user != nil {
            password.removeAll()
        }
        banner = Banner(style: .success, message: message)
        isLoading = false
    }

    @MainActor
    func handleFailure(_ error: Error) {
        let authError = error as? AuthError ?? .unknown(message: error.localizedDescription)
        if authError == .userCancelled {
            banner = Banner(style: .info, message: authError.userMessage)
            isLoading = false
            return
        }
        banner = Banner(style: .error, message: authError.userMessage)
        isLoading = false
    }

    func observeAuthState() {
        authObservationTask = Task { [weak self] in
            guard let self else { return }
            for await state in observeAuthStateUseCase.execute() {
                self.updateAuthState(state)
            }
        }
    }

    @MainActor
    func updateAuthState(_ state: AuthState) {
        authState = state
    }

    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

#if DEBUG
extension LoginViewModel {
    public static func preview() -> LoginViewModel {
        let repository = PreviewAuthRepository()
        return LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            registerUseCase: RegisterUseCase(repository: repository),
            googleSignInUseCase: SignInWithGoogleUseCase(repository: repository),
            googleSignInHandler: PreviewGoogleSignInHandler(),
            passwordResetUseCase: SendPasswordResetUseCase(repository: repository),
            logoutUseCase: LogoutUseCase(repository: repository),
            observeAuthStateUseCase: ObserveAuthStateUseCase(repository: repository)
        )
    }
}

#endif
