import Data
import Domain
import Presentation

/// Factory surface to create login view models without binding callers to the concrete container.
protocol LoginViewModelBuilding {
    func makeLoginViewModel() -> LoginViewModel
}

protocol PasswordResetViewModelBuilding {
    func makePasswordResetViewModel() -> PasswordResetViewModel
}

/// Contract for clearing app/session state (listeners, caches) on logout.
protocol SessionResetting {
    func resetSession() async
}

/// Minimal auth session actions needed outside the login screen.
protocol AuthSessionHandling {
    func logout() async throws
}

/// Simple composition root wiring Firebase-backed dependencies.
@MainActor
final class AppContainer: LoginViewModelBuilding,
                            PasswordResetViewModelBuilding,
                            AuthSessionHandling,
                            SessionResetting {
    private let authRepository: AuthRepositoryProtocol
    private let googleSignInHandler: GoogleSignInHandling

    init() {
        let dataSource = FirebaseAuthDataSource()
        self.authRepository = AuthRepository(dataSource: dataSource)
        self.googleSignInHandler = GoogleSignInAdapter()
    }

    func makeLoginViewModel() -> LoginViewModel {
        let login = LoginUseCase(repository: authRepository)
        let register = RegisterUseCase(repository: authRepository)
        let google = SignInWithGoogleUseCase(repository: authRepository)
        let reset = SendPasswordResetUseCase(repository: authRepository)
        let logout = LogoutUseCase(repository: authRepository)
        let observe = ObserveAuthStateUseCase(repository: authRepository)

        return LoginViewModel(
            loginUseCase: login,
            registerUseCase: register,
            googleSignInUseCase: google,
            googleSignInHandler: googleSignInHandler,
            passwordResetUseCase: reset,
            logoutUseCase: logout,
            observeAuthStateUseCase: observe
        )
    }

    func makePasswordResetViewModel() -> PasswordResetViewModel {
        PasswordResetViewModel(
            resetUseCase: SendPasswordResetUseCase(repository: authRepository)
        )
    }

    func resetSession() async {
        // No listeners/caches yet; hook repositories here when available.
    }

    func logout() async throws {
        let logout = LogoutUseCase(repository: authRepository)
        try await logout.execute()
    }
}
