import Shared

public struct SignInWithGoogleUseCase: Sendable {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(idToken: String, accessToken: String) async throws -> AuthUser {
        try await repository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}
