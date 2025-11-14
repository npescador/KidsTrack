import Domain
import Foundation
@testable import Presentation
import Shared
import Testing

@Suite("LoginViewModel")
struct LoginViewModelTests {
    @Test("Login success updates banner")
    func loginSuccess() async throws {
        let (viewModel, repository) = makeSystem()
        repository.nextResult = .success(.init(id: "abc", email: "user@test.com"))
        viewModel.email = "user@test.com"
        viewModel.password = "secret"

        viewModel.login()

        try await waitUntil { viewModel.banner?.style == .success }
        #expect(viewModel.password.isEmpty)
        #expect(!viewModel.isLoading)
    }

    @Test("Login failure surfaces domain error")
    func loginFailure() async throws {
        let (viewModel, repository) = makeSystem()
        repository.nextResult = .failure(.invalidCredentials)
        viewModel.email = "user@test.com"
        viewModel.password = "bad"

        viewModel.login()

        try await waitUntil { viewModel.banner?.style == .error }
        #expect(viewModel.banner?.message.contains("invalid") == true)
    }

    @Test("Register success message appears")
    func registerSuccess() async throws {
        let (viewModel, repository) = makeSystem()
        repository.nextResult = .success(.init(id: "abc", email: "new@test.com"))
        viewModel.email = "new@test.com"
        viewModel.password = "123456"

        viewModel.register()

        try await waitUntil { viewModel.banner?.style == .success }
    }

    @Test("Password reset errors are presented")
    func passwordResetError() async throws {
        let (viewModel, repository) = makeSystem()
        repository.resetError = .userNotFound
        viewModel.email = "none@test.com"

        viewModel.sendPasswordReset()

        try await waitUntil { viewModel.banner?.style == .error }
        #expect(viewModel.banner?.message.contains("No account") == true)
    }

    @Test("Logout emits success after state observer authenticates user")
    func logoutFlow() async throws {
        let (viewModel, repository) = makeSystem()
        repository.emit(state: .authenticated(.init(id: "abc", email: "me@test.com")))
        try await waitUntil { viewModel.isAuthenticated }

        viewModel.logout()

        try await waitUntil { repository.logoutCallCount == 1 }
        #expect(viewModel.banner?.style == .success)
    }

    private func makeSystem() -> (LoginViewModel, MockAuthRepository) {
        let repository = MockAuthRepository()
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            registerUseCase: RegisterUseCase(repository: repository),
            passwordResetUseCase: SendPasswordResetUseCase(repository: repository),
            logoutUseCase: LogoutUseCase(repository: repository),
            observeAuthStateUseCase: ObserveAuthStateUseCase(repository: repository)
        )
        return (viewModel, repository)
    }
}

private final class MockAuthRepository: AuthRepositoryProtocol {
    var nextResult: Result<AuthUser, AuthError> = .success(.init(id: "", email: ""))
    var resetError: AuthError?
    var logoutCallCount = 0
    private var continuation: AsyncStream<AuthState>.Continuation?

    func login(email: String, password: String) async throws -> AuthUser {
        try nextResult.get()
    }

    func register(email: String, password: String) async throws -> AuthUser {
        try nextResult.get()
    }

    func sendPasswordReset(email: String) async throws {
        if let resetError {
            throw resetError
        }
    }

    func logout() async throws {
        logoutCallCount += 1
    }

    func observeAuthState() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(.unauthenticated)
        }
    }

    func emit(state: AuthState) {
        continuation?.yield(state)
    }
}

private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while clock.now < deadline {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: 20_000_000)
    }

    throw WaitError.timeout
}

enum WaitError: Error {
    case timeout
}
