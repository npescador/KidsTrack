import Shared

public struct CreateFamilyUseCase: Sendable {
    private let repository: FamilyRepositoryProtocol
    private let activeStore: ActiveFamilyStoreProtocol

    public init(
        repository: FamilyRepositoryProtocol,
        activeStore: ActiveFamilyStoreProtocol
    ) {
        self.repository = repository
        self.activeStore = activeStore
    }

    public func execute(name: String, ownerId: String) async throws -> Family {
        let family = try await repository.createFamily(name: name, ownerId: ownerId)
        await activeStore.setActiveFamily(family)
        return family
    }
}
