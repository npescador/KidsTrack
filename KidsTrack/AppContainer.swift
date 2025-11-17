import Data
import Domain
import Presentation

/// Simple composition root wiring Firebase-backed dependencies.
@MainActor
final class AppContainer {
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
}
