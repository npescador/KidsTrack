import Domain
import Presentation
import Shared
import Testing

@MainActor
@Suite("CreateFamilyViewModel")
struct CreateFamilyViewModelTests {
    @Test("Valid form triggers repository and sets banner on success")
    func createFamilySuccess() async throws {
        let system = makeSystem()
        system.repository.nextResult = .success(
            Family(id: "fam-123", name: "Pescador", ownerId: "user-123")
        )
        system.viewModel.name = "Pescador"

        system.viewModel.createFamily()
        try await waitUntil {
            system.store.storedFamily?.name == "Pescador"
                && system.viewModel.createdFamily != nil
                && system.viewModel.banner != nil
        }

        #expect(system.repository.receivedName == "Pescador")
        #expect(system.store.storedFamily?.name == "Pescador")
        #expect(system.viewModel.banner?.isError == false)
        #expect(system.viewModel.createdFamily?.ownerId == "user-123")
    }

    @Test("Empty name shows validation banner and does not call repository")
    func emptyNameValidation() async throws {
        let system = makeSystem()
        system.viewModel.name = "   "

        system.viewModel.createFamily()
        try await waitUntil { system.viewModel.banner != nil }

        #expect(system.repository.receivedName == nil)
        #expect(system.viewModel.banner?.isError == true)
    }

    @Test("Missing session surfaces error")
    func missingSession() async throws {
        let repository = MockFamilyRepository()
        let store = MockActiveFamilyStore()
        let session = MockUserSessionProvider(currentUser: nil)
        let viewModel = CreateFamilyViewModel(
            createFamilyUseCase: CreateFamilyUseCase(repository: repository, activeStore: store),
            sessionProvider: session
        )
        viewModel.name = "Family"

        viewModel.createFamily()
        try await Task.sleep(nanoseconds: 5_000_000)

        #expect(repository.receivedName == nil)
        #expect(viewModel.banner?.isError == true)
    }

    @Test("Repository errors map to banner")
    func surfacesRepositoryErrors() async throws {
        let system = makeSystem()
        system.repository.nextResult = .failure(AuthError.network)
        system.viewModel.name = "Networked"

        system.viewModel.createFamily()
        try await waitUntil { system.viewModel.banner != nil }

        #expect(system.viewModel.banner?.isError == true)
        #expect(system.viewModel.banner?.message == AuthError.network.userMessage)
    }
}

private extension CreateFamilyViewModelTests {
    struct System {
        let viewModel: CreateFamilyViewModel
        let repository: MockFamilyRepository
        let store: MockActiveFamilyStore
    }

    func makeSystem() -> System {
        let repository = MockFamilyRepository()
        let store = MockActiveFamilyStore()
        let session = MockUserSessionProvider(currentUser: AuthUser(id: "user-123", email: "demo@kidstrack.app"))
        let viewModel = CreateFamilyViewModel(
            createFamilyUseCase: CreateFamilyUseCase(repository: repository, activeStore: store),
            sessionProvider: session
        )
        return System(viewModel: viewModel, repository: repository, store: store)
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
