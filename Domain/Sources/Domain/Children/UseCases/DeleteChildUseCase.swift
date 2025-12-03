import Shared

public struct DeleteChildUseCase: Sendable {
    private let repository: ChildrenRepositoryProtocol

    public init(repository: ChildrenRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String, familyId: String) async throws {
        try await repository.deleteChild(id: id, familyId: familyId)
    }
}
