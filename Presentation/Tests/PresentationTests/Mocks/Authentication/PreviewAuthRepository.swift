import Domain
import Shared

final class PreviewAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    func login(email: String, password: String) async throws -> AuthUser {
        AuthUser(id: UUID().uuidString, email: email)
    }

    func register(email: String, password: String) async throws -> AuthUser {
        AuthUser(id: UUID().uuidString, email: email)
    }

    func sendPasswordReset(email: String) async throws {}

    func logout() async throws {}

    func observeAuthState() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            continuation.yield(.unauthenticated)
        }
    }
}
