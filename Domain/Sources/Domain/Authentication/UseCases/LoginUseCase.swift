import Shared

public struct LoginUseCase: Sendable {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String, password: String) async throws -> AuthUser {
        try await repository.login(email: email, password: password)
    }
}
