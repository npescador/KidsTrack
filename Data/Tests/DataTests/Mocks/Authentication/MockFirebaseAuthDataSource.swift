import Data
import Shared

final class MockFirebaseAuthDataSource: FirebaseAuthDataSourceProtocol, @unchecked Sendable {
    var loginResult: Result<AuthUser, AuthError> = .success(.init(id: "", email: ""))
    var resetError: AuthError?
    var didLogout = false
    var receivedEmail: String?
    var stateContinuation: AsyncStream<AuthState>.Continuation?
    var googleResult: Result<AuthUser, AuthError> = .success(.init(id: "", email: "google@test.com"))

    func login(email: String, password: String) async throws -> AuthUser {
        receivedEmail = email
        return try loginResult.get()
    }

    func register(email: String, password: String) async throws -> AuthUser {
        receivedEmail = email
        return try loginResult.get()
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthUser {
        try googleResult.get()
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
            stateContinuation = continuation
        }
    }
}
