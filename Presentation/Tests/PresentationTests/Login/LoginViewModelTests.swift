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
        let system = makeSystem()
        system.repository.nextResult = .success(.init(id: "abc", email: "user@test.com"))
        system.viewModel.email = "user@test.com"
        system.viewModel.password = "secret"

        system.viewModel.login()

        try await waitUntil { system.viewModel.banner?.style == .success }
        #expect(system.viewModel.password.isEmpty)
        #expect(!system.viewModel.isLoading)
    }

    @Test("Login failure surfaces domain error")
    func loginFailure() async throws {
        let system = makeSystem()
        system.repository.nextResult = .failure(.invalidCredentials)
        system.viewModel.email = "user@test.com"
        system.viewModel.password = "bad"

        system.viewModel.login()

        try await waitUntil { system.viewModel.banner?.style == .error }
        #expect(system.viewModel.banner?.message.contains("invalid") == true)
    }

    @Test("Register success message appears")
    func registerSuccess() async throws {
        let system = makeSystem()
        system.repository.nextResult = .success(.init(id: "abc", email: "new@test.com"))
        system.viewModel.email = "new@test.com"
        system.viewModel.password = "123456"

        system.viewModel.register()

        try await waitUntil { system.viewModel.banner?.style == .success }
    }

    @Test("Password reset errors are presented")
    func passwordResetError() async throws {
        let system = makeSystem()
        system.repository.resetResult = .failure(.userNotFound)
        system.viewModel.email = "none@test.com"

        system.viewModel.sendPasswordReset()

        try await waitUntil { system.viewModel.banner?.style == .error }
        #expect(system.viewModel.banner?.message.contains("No account") == true)
    }

    @Test("Logout emits success after state observer authenticates user")
    func logoutFlow() async throws {
        let system = makeSystem()
        system.repository.emit(state: .authenticated(.init(id: "abc", email: "me@test.com")))
        try await waitUntil { system.viewModel.isAuthenticated }

        system.viewModel.logout()

        try await waitUntil { system.repository.logoutCallCount == 1 }
        #expect(system.viewModel.banner?.style == .success)
    }

    @Test("Register blocks short passwords")
    func registerShortPassword() {
        let system = makeSystem()
        system.viewModel.email = "new@test.com"
        system.viewModel.password = "123"

        system.viewModel.register()

        #expect(system.repository.registerCallCount == 0)
        #expect(system.viewModel.banner?.style == .error)
    }

    @Test("Login blocks invalid email format")
    func loginInvalidEmail() {
        let system = makeSystem()
        system.viewModel.email = "invalid-email"
        system.viewModel.password = "password"

        system.viewModel.login()

        #expect(system.repository.loginCallCount == 0)
        #expect(system.viewModel.banner?.style == .error)
    }

    @Test("Google sign-in succeeds and updates banner")
    func googleSignInSuccess() async throws {
        let system = makeSystem()
        system.repository.nextResult = .success(.init(id: "google-123", email: "g@test.com"))

        system.viewModel.signInWithGoogle(presentingViewController: UIViewController())

        try await waitUntil { system.viewModel.banner?.style == .success }
        #expect(system.repository.googleCallCount == 1)
    }

    @Test("Google sign-in cancellation shows info banner and skips repository call")
    func googleSignInCancelled() async throws {
        let system = makeSystem(googleResult: .failure(AuthError.userCancelled))
        system.repository.nextResult = .success(.init(id: "google-123", email: "g@test.com"))

        system.viewModel.signInWithGoogle(presentingViewController: UIViewController())

        try await waitUntil { system.viewModel.banner?.style == .info }
        #expect(system.repository.googleCallCount == 0)
        #expect(!system.viewModel.isLoading)
    }

    private func makeSystem(
        googleResult: Result<GoogleSignInTokens, Error> = .success(
            GoogleSignInTokens(
                idToken: "id",
                accessToken: "token"
            )
        )
    ) -> System {
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
        return System(viewModel: viewModel, repository: repository, googleHandler: googleHandler)
    }
}

private struct System {
    let viewModel: LoginViewModel
    let repository: MockAuthRepository
    let googleHandler: GoogleSignInHandlerStub
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
