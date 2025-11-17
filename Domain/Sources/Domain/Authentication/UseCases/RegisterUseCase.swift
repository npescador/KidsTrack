import Shared

public struct RegisterUseCase: Sendable {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String, password: String) async throws -> AuthUser {
        try await repository.register(email: email, password: password)
    }
}
