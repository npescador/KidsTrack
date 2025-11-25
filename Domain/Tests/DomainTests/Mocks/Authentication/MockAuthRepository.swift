import Domain
import Shared
import Testing

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var nextUserResult: Result<AuthUser, AuthError>?
    var resetError: AuthError?
    var didLogout = false
    var stateStreamContinuation: AsyncStream<AuthState>.Continuation?

    func login(email: String, password: String) async throws -> AuthUser {
        guard let nextUserResult else {
            Issue.record("nextUserResult must be set before calling login")
            throw AuthError.missingImplementation
        }
        return try nextUserResult.get()
    }

    func register(email: String, password: String) async throws -> AuthUser {
        guard let nextUserResult else {
            Issue.record("nextUserResult must be set before calling register")
            throw AuthError.missingImplementation
        }
        return try nextUserResult.get()
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthUser {
        guard let nextUserResult else {
            Issue.record("nextUserResult must be set before calling signInWithGoogle")
            throw AuthError.missingImplementation
        }
        return try nextUserResult.get()
    }

    func sendPasswordReset(email: String) async throws {
        if let resetError {
            throw resetError
        }
    }

    func logout() async throws {
        didLogout = true
    }

    func observeAuthState() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            stateStreamContinuation = continuation
        }
    }
}
