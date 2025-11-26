import Domain
import Shared
import Testing

@Suite("CreateFamilyUseCase")
struct CreateFamilyUseCaseTests {
    private let repository = MockFamilyRepository()
    private let activeStore = MockActiveFamilyStore()

    private var useCase: CreateFamilyUseCase {
        CreateFamilyUseCase(repository: repository, activeStore: activeStore)
    }

    @Test("Creates a family and stores it as active")
    func createAndSetActive() async throws {
        let expected = Family(id: "family-123", name: "Pescador", ownerId: "owner-1")
        repository.nextResult = .success(expected)

        let family = try await useCase.execute(name: expected.name, ownerId: expected.ownerId)

        #expect(family == expected)
        let stored = await activeStore.activeFamily()
        #expect(stored == expected)
        #expect(repository.receivedName == expected.name)
        #expect(repository.receivedOwnerId == expected.ownerId)
    }

    @Test("Bubbles repository errors")
    func propagatesErrors() async {
        enum SampleError: Error { case failed }
        repository.nextResult = .failure(SampleError.failed)

        do {
            _ = try await useCase.execute(name: "Err", ownerId: "owner")
            Issue.record("Expected failure")
        } catch {
            #expect(error is SampleError)
        }
    }
}
