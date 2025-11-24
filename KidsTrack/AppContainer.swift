import Data
import Domain
import Presentation

/// Factory surface to create login view models without binding callers to the concrete container.
protocol LoginViewModelBuilding {
    func makeLoginViewModel() -> LoginViewModel
}

/// Minimal auth session actions needed outside the login screen.
protocol AuthSessionHandling {
    func logout() async throws
}

/// Simple composition root wiring Firebase-backed dependencies.
@MainActor
final class AppContainer: LoginViewModelBuilding, AuthSessionHandling {
    private let authRepository: AuthRepositoryProtocol

    init() {
        let dataSource = FirebaseAuthDataSource()
        self.authRepository = AuthRepository(dataSource: dataSource)
    }

    func makeLoginViewModel() -> LoginViewModel {
        let login = LoginUseCase(repository: authRepository)
        let register = RegisterUseCase(repository: authRepository)
        let reset = SendPasswordResetUseCase(repository: authRepository)
        let logout = LogoutUseCase(repository: authRepository)
        let observe = ObserveAuthStateUseCase(repository: authRepository)

        return LoginViewModel(
            loginUseCase: login,
            registerUseCase: register,
            passwordResetUseCase: reset,
            logoutUseCase: logout,
            observeAuthStateUseCase: observe
        )
    }

    func logout() async throws {
        let logout = LogoutUseCase(repository: authRepository)
        try await logout.execute()
    }
}
