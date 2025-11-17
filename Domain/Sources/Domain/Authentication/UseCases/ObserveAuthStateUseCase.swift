import Shared

public struct ObserveAuthStateUseCase: Sendable {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<AuthState> {
        repository.observeAuthState()
    }
}
