import Shared

public struct UpdateChildUseCase: Sendable {
    private let repository: ChildrenRepositoryProtocol

    public init(repository: ChildrenRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ request: UpdateChildRequest) async throws -> Child {
        try await repository.updateChild(request)
    }
}
