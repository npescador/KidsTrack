import Shared

public struct SetActiveFamilyUseCase: Sendable {
    private let store: ActiveFamilyStoreProtocol

    public init(store: ActiveFamilyStoreProtocol) {
        self.store = store
    }

    public func execute(_ family: Family) async {
        await store.setActiveFamily(family)
    }
}
