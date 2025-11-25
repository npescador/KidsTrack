import Domain
import Shared
import Testing

@Suite("Auth Use Cases")
struct AuthUseCasesTests {
    private let repository = MockAuthRepository()

    private var loginUseCase: LoginUseCase { LoginUseCase(repository: repository) }
    private var registerUseCase: RegisterUseCase { RegisterUseCase(repository: repository) }
    private var googleUseCase: SignInWithGoogleUseCase { SignInWithGoogleUseCase(repository: repository) }
    private var resetUseCase: SendPasswordResetUseCase { SendPasswordResetUseCase(repository: repository) }
    private var logoutUseCase: LogoutUseCase { LogoutUseCase(repository: repository) }
    private var observeUseCase: ObserveAuthStateUseCase {
        ObserveAuthStateUseCase(repository: repository)
    }

    @Test("Login succeeds with credentials")
    func loginSuccess() async throws {
        repository.nextUserResult = .success(.init(id: "abc", email: "user@test.com"))
        let user = try await loginUseCase.execute(email: "user@test.com", password: "secret")
        #expect(user.email == "user@test.com")
    }

    @Test("Login propagates invalid credentials")
    func loginFailure() async {
        repository.nextUserResult = .failure(.invalidCredentials)

        do {
            _ = try await loginUseCase.execute(email: "user@test.com", password: "bad")
            Issue.record("Expected error")
        } catch {
            #expect(error as? AuthError == .invalidCredentials)
        }
    }

    @Test("Register yields new user")
    func registerSuccess() async throws {
        repository.nextUserResult = .success(.init(id: "xyz", email: "new@test.com"))
        let user = try await registerUseCase.execute(email: "new@test.com", password: "pass")
        #expect(user.id == "xyz")
    }

    @Test("Register surfaces duplicate user error")
    func registerDuplicate() async {
        repository.nextUserResult = .failure(.userAlreadyExists)

        do {
            _ = try await registerUseCase.execute(email: "new@test.com", password: "pass")
            Issue.record("Expected duplicate error")
        } catch {
            #expect(error as? AuthError == .userAlreadyExists)
        }
    }

    @Test("Google sign-in returns user")
    func googleSignInSuccess() async throws {
        repository.nextUserResult = .success(.init(id: "google-123", email: "user@test.com"))
        let user = try await googleUseCase.execute(idToken: "id", accessToken: "token")
        #expect(user.id == "google-123")
    }

    @Test("Google sign-in surfaces errors")
    func googleSignInFailure() async {
        repository.nextUserResult = .failure(.network)

        do {
            _ = try await googleUseCase.execute(idToken: "id", accessToken: "token")
            Issue.record("Expected network error")
        } catch {
            #expect(error as? AuthError == .network)
        }
    }

    @Test("Password reset bubbles repository errors")
    func passwordResetError() async {
        repository.resetError = .userNotFound

        do {
            try await resetUseCase.execute(email: "missing@test.com")
            Issue.record("Expected error not thrown")
        } catch {
            #expect(error as? AuthError == .userNotFound)
        }
    }

    @Test("Logout invokes repository")
    func logoutSuccess() async throws {
        try await logoutUseCase.execute()
        #expect(repository.didLogout)
    }

    @Test("Auth state stream forwards values")
    func observeAuthState() async throws {
        let stream = observeUseCase.execute()

        repository.stateStreamContinuation?.yield(.authenticated(.init(id: "123", email: "me@test.com")))
        if let next = await firstValue(from: stream) {
            #expect(next == .authenticated(.init(id: "123", email: "me@test.com")))
        } else {
            Issue.record("Expected auth state emission")
        }
    }
}

private func firstValue(from stream: AsyncStream<AuthState>) async -> AuthState? {
    for await value in stream {
        return value
    }
    return nil
}
