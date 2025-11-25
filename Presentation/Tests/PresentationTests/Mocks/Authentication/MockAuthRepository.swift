import Domain
import Shared

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<AuthUser, AuthError> = .success(.init(id: "", email: ""))
    var resetResult: Result<Void, AuthError> = .success(())
    var logoutCallCount = 0
    var loginCallCount = 0
    var registerCallCount = 0
    var resetCallCount = 0
    var googleCallCount = 0
    private var continuation: AsyncStream<AuthState>.Continuation?
    private var pendingStates: [AuthState] = []

    func login(email: String, password: String) async throws -> AuthUser {
        loginCallCount += 1
        return try nextResult.get()
    }

    func register(email: String, password: String) async throws -> AuthUser {
        registerCallCount += 1
        return try nextResult.get()
    }

    func sendPasswordReset(email: String) async throws {
        resetCallCount += 1
        switch resetResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthUser {
        googleCallCount += 1
        return try nextResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
    }

    func observeAuthState() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(.unauthenticated)
            pendingStates.forEach { continuation.yield($0) }
            pendingStates.removeAll()
        }
    }

    func emit(state: AuthState) {
        if let continuation {
            continuation.yield(state)
        } else {
            pendingStates.append(state)
        }
    }
}
