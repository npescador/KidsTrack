import Domain
import Foundation
@testable import Presentation
import Shared
import Testing
import UIKit

@MainActor
@Suite("LoginViewModel")
struct LoginViewModelTests {
    @Test("Login success updates banner")
    func loginSuccess() async throws {
        let (viewModel, repository, _) = makeSystem()
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
        let (viewModel, repository, _) = makeSystem()
        repository.nextResult = .failure(.invalidCredentials)
        viewModel.email = "user@test.com"
        viewModel.password = "bad"

        viewModel.login()

        try await waitUntil { viewModel.banner?.style == .error }
        #expect(viewModel.banner?.message.contains("invalid") == true)
    }

    @Test("Register success message appears")
    func registerSuccess() async throws {
        let (viewModel, repository, _) = makeSystem()
        repository.nextResult = .success(.init(id: "abc", email: "new@test.com"))
        viewModel.email = "new@test.com"
        viewModel.password = "123456"

        viewModel.register()

        try await waitUntil { viewModel.banner?.style == .success }
    }

    @Test("Password reset errors are presented")
    func passwordResetError() async throws {
        let (viewModel, repository, _) = makeSystem()
        repository.resetResult = .failure(.userNotFound)
        viewModel.email = "none@test.com"

        viewModel.sendPasswordReset()

        try await waitUntil { viewModel.banner?.style == .error }
        #expect(viewModel.banner?.message.contains("No account") == true)
    }

    @Test("Logout emits success after state observer authenticates user")
    func logoutFlow() async throws {
        let (viewModel, repository, _) = makeSystem()
        repository.emit(state: .authenticated(.init(id: "abc", email: "me@test.com")))
        try await waitUntil { viewModel.isAuthenticated }

        viewModel.logout()

        try await waitUntil { repository.logoutCallCount == 1 }
        #expect(viewModel.banner?.style == .success)
    }

    @Test("Register blocks short passwords")
    func registerShortPassword() {
        let (viewModel, repository, _) = makeSystem()
        viewModel.email = "new@test.com"
        viewModel.password = "123"

        viewModel.register()

        #expect(repository.registerCallCount == 0)
        #expect(viewModel.banner?.style == .error)
    }

    @Test("Login blocks invalid email format")
    func loginInvalidEmail() {
        let (viewModel, repository, _) = makeSystem()
        viewModel.email = "invalid-email"
        viewModel.password = "password"

        viewModel.login()

        #expect(repository.loginCallCount == 0)
        #expect(viewModel.banner?.style == .error)
    }

    @Test("Google sign-in succeeds and updates banner")
    func googleSignInSuccess() async throws {
        let (viewModel, repository, _) = makeSystem()
        repository.nextResult = .success(.init(id: "google-123", email: "g@test.com"))

        viewModel.signInWithGoogle(presentingViewController: UIViewController())

        try await waitUntil { viewModel.banner?.style == .success }
        #expect(repository.googleCallCount == 1)
    }

    @Test("Google sign-in cancellation shows info banner and skips repository call")
    func googleSignInCancelled() async throws {
        let (viewModel, repository, _) = makeSystem(googleResult: .failure(AuthError.userCancelled))
        repository.nextResult = .success(.init(id: "google-123", email: "g@test.com"))

        viewModel.signInWithGoogle(presentingViewController: UIViewController())

        try await waitUntil { viewModel.banner?.style == .info }
        #expect(repository.googleCallCount == 0)
        #expect(!viewModel.isLoading)
    }

    private func makeSystem(
        googleResult: Result<GoogleSignInTokens, Error> = .success(
            GoogleSignInTokens(
                idToken: "id",
                accessToken: "token"
            )
        )
    ) -> (LoginViewModel, MockAuthRepository, GoogleSignInHandlerStub) {
        let repository = MockAuthRepository()
        let googleHandler = GoogleSignInHandlerStub(result: googleResult)
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            registerUseCase: RegisterUseCase(repository: repository),
            googleSignInUseCase: SignInWithGoogleUseCase(repository: repository),
            googleSignInHandler: googleHandler,
            passwordResetUseCase: SendPasswordResetUseCase(repository: repository),
            logoutUseCase: LogoutUseCase(repository: repository),
            observeAuthStateUseCase: ObserveAuthStateUseCase(repository: repository)
        )
        return (viewModel, repository, googleHandler)
    }
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping @MainActor () -> Bool
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
