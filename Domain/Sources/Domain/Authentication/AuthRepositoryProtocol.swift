import Shared

public protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws -> AuthUser
    func register(email: String, password: String) async throws -> AuthUser
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthUser
    func sendPasswordReset(email: String) async throws
    func logout() async throws
    func observeAuthState() -> AsyncStream<AuthState>
}
