import Shared

public struct CreateChildUseCase: Sendable {
    private let repository: ChildrenRepositoryProtocol

    public init(repository: ChildrenRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ request: CreateChildRequest) async throws -> Child {
        try await repository.createChild(request)
    }
}
