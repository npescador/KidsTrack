public struct SendPasswordResetUseCase: Sendable {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String) async throws {
        try await repository.sendPasswordReset(email: email)
    }
}
