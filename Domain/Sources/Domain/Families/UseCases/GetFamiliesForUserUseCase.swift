import Shared

public struct GetFamiliesForUserUseCase: Sendable {
    private let repository: FamilyRepositoryProtocol

    public init(repository: FamilyRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userId: String) async throws -> [Family] {
        try await repository.fetchFamilies(for: userId)
    }
}
