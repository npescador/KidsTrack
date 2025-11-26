import Domain
import Shared
import Testing

@Suite("SetActiveFamilyUseCase")
struct SetActiveFamilyUseCaseTests {
    @Test("Stores active family in the store")
    func setsActiveFamily() async {
        let store = MockActiveFamilyStore()
        let useCase = SetActiveFamilyUseCase(store: store)
        let family = Family(id: "1", name: "Pescador", ownerId: "u1")

        await useCase.execute(family)

        let stored = await store.activeFamily()
        #expect(stored == family)
    }
}
