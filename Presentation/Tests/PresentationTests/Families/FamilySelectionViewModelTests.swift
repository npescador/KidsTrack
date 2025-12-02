import Domain
import Presentation
import Shared
import Testing

@MainActor
@Suite("FamilySelectionViewModel")
struct FamilySelectionViewModelTests {
    @Test("Loads families and selects first when no active family stored")
    func loadsFamilies() async throws {
        let system = makeSystem()
        system.repository.fetchResult = .success([
            Family(id: "1", name: "Alpha", ownerId: "u1"),
            Family(id: "2", name: "Beta", ownerId: "u1")
        ])

        system.viewModel.load()

        try await waitUntil { if case .loaded = system.viewModel.state { return true } else { return false } }
        #expect(system.viewModel.activeFamily?.id == "1")
        #expect(system.store.storedFamily?.id == "1")
    }

    @Test("Keeps stored active family when loading")
    func preservesStoredActive() async throws {
        let system = makeSystem()
        let stored = Family(id: "stored", name: "Stored", ownerId: "u1")
        await system.store.setActiveFamily(stored)
        system.repository.fetchResult = .success([
            stored,
            Family(id: "2", name: "Beta", ownerId: "u1")
        ])

        system.viewModel.load()

        try await waitUntil { if case .loaded = system.viewModel.state { return true } else { return false } }
        #expect(system.viewModel.activeFamily?.id == "stored")
    }

    @Test("Selecting a family persists it")
    func selectsFamily() async throws {
        let system = makeSystem()
        let families = [
            Family(id: "1", name: "Alpha", ownerId: "u1"),
            Family(id: "2", name: "Beta", ownerId: "u1")
        ]
        system.repository.fetchResult = .success(families)
        system.viewModel.load()
        try await waitUntil {
            if case let .loaded(list) = system.viewModel.state,
               !list.isEmpty { return true } else { return false }
        }

        system.viewModel.select(families[1])
        try await waitUntil { system.store.storedFamily?.id == "2" }

        #expect(system.viewModel.activeFamily?.id == "2")
    }

    @Test("Handles created family by appending and selecting")
    func handlesCreatedFamily() async throws {
        let system = makeSystem()
        system.repository.fetchResult = .success([
            Family(id: "1", name: "Alpha", ownerId: "u1")
        ])
        system.viewModel.load()
        try await waitUntil { if case .loaded = system.viewModel.state { return true } else { return false } }

        let created = Family(id: "new", name: "New Fam", ownerId: "u1")
        system.viewModel.handleCreated(created)
        try await waitUntil { system.viewModel.activeFamily?.id == "new" }

        if case let .loaded(list) = system.viewModel.state {
            #expect(list.contains(where: { $0.id == "new" }))
        } else {
            Issue.record("Expected loaded state")
        }
    }

    @Test("Surfaces error when repository fails")
    func surfacesError() async throws {
        let system = makeSystem()
        system.repository.fetchResult = .failure(MockFamilyRepositoryError.missingResult)

        system.viewModel.load()

        try await waitUntil { if case .error = system.viewModel.state { return true } else { return false } }
    }

    @Test("Switching family triggers realtime syncer")
    func notifiesRealtimeSyncer() async throws {
        let system = makeSystem(includeSyncer: true)
        let families = [
            Family(id: "1", name: "Alpha", ownerId: "u1"),
            Family(id: "2", name: "Beta", ownerId: "u1")
        ]
        system.repository.fetchResult = .success(families)
        system.viewModel.load()

        try await waitUntil {
            if case let .loaded(list) = system.viewModel.state,
               !list.isEmpty { return true }
            return false
        }

        system.viewModel.select(families[1])
        try await waitUntil { system.syncer?.switchedFamilies.contains("2") == true }
    }

    @Test("Loads stored active family and resumes realtime")
    func resumesRealtimeForStoredFamily() async throws {
        let system = makeSystem(includeSyncer: true)
        let stored = Family(id: "stored", name: "Stored", ownerId: "u1")
        await system.store.setActiveFamily(stored)
        system.repository.fetchResult = .success([stored])

        system.viewModel.load()

        try await waitUntil { if case .loaded = system.viewModel.state { return true } else { return false } }
        #expect(system.viewModel.activeFamily?.id == "stored")
        #expect(system.syncer?.switchedFamilies.contains("stored") == true)
    }
}

private extension FamilySelectionViewModelTests {
    enum MockFamilyRepositoryError: Error {
        case missingResult
    }

    struct System {
        let viewModel: FamilySelectionViewModel
        let repository: MockFamilyRepository
        let store: MockActiveFamilyStore
        let syncer: MockFamilyRealtimeSyncer?
    }

    func makeSystem(includeSyncer: Bool = false) -> System {
        let repository = MockFamilyRepository()
        let store = MockActiveFamilyStore()
        let session = MockUserSessionProvider(currentUser: AuthUser(id: "u1", email: "user@test.com"))
        let syncer = includeSyncer ? MockFamilyRealtimeSyncer() : nil
        let viewModel = FamilySelectionViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: repository),
            setActiveFamily: SetActiveFamilyUseCase(store: store),
            activeFamilyStore: store,
            sessionProvider: session,
            realtimeSyncer: syncer
        )
        return System(viewModel: viewModel, repository: repository, store: store, syncer: syncer)
    }
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping @MainActor () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while clock.now < deadline {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: 20_000_000)
    }

    throw WaitError.timeout
}
