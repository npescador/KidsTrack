import Domain
import Shared

public final class AuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private let dataSource: FirebaseAuthDataSourceProtocol

    public init(dataSource: FirebaseAuthDataSourceProtocol) {
        self.dataSource = dataSource
    }

    public func login(email: String, password: String) async throws -> AuthUser {
        try await dataSource.login(email: email, password: password)
    }

    public func register(email: String, password: String) async throws -> AuthUser {
        try await dataSource.register(email: email, password: password)
    }

    public func sendPasswordReset(email: String) async throws {
        try await dataSource.sendPasswordReset(email: email)
    }

    public func logout() async throws {
        try await dataSource.logout()
    }

    public func observeAuthState() -> AsyncStream<AuthState> {
        dataSource.observeAuthState()
    }
}
