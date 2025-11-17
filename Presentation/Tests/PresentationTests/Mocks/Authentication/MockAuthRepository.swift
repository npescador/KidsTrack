import Domain
import Shared

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<AuthUser, AuthError> = .success(.init(id: "", email: ""))
    var resetError: AuthError?
    var logoutCallCount = 0
    private var continuation: AsyncStream<AuthState>.Continuation?
    private var pendingStates: [AuthState] = []

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
