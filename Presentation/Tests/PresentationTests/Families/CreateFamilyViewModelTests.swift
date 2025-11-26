import Domain
import Shared
import Testing

@Suite("CreateFamilyViewModel")
struct CreateFamilyViewModelTests {
    @Test("Valid form triggers repository and sets banner on success")
    func createFamilySuccess() async throws {
        let (viewModel, repository, store) = makeSystem()
        viewModel.name = "Pescador"

        viewModel.createFamily()
        try await Task.sleep(nanoseconds: 10_000_000)

        #expect(repository.receivedName == "Pescador")
        #expect(store.storedFamily?.name == "Pescador")
        #expect(viewModel.banner?.isError == false)
        #expect(viewModel.createdFamily?.ownerId == "user-123")
    }

    @Test("Empty name shows validation banner and does not call repository")
    func emptyNameValidation() async throws {
        let (viewModel, repository, _) = makeSystem()
        viewModel.name = "   "

        viewModel.createFamily()
        try await Task.sleep(nanoseconds: 5_000_000)

        #expect(repository.receivedName == nil)
        #expect(viewModel.banner?.isError == true)
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
        let (viewModel, repository, _) = makeSystem()
        repository.nextResult = .failure(AuthError.network)
        viewModel.name = "Networked"

        viewModel.createFamily()
        try await Task.sleep(nanoseconds: 5_000_000)

        #expect(viewModel.banner?.isError == true)
        #expect(viewModel.banner?.message == AuthError.network.userMessage)
    }
}

private extension CreateFamilyViewModelTests {
    func makeSystem() -> (CreateFamilyViewModel, MockFamilyRepository, MockActiveFamilyStore) {
        let repository = MockFamilyRepository()
        let store = MockActiveFamilyStore()
        let session = MockUserSessionProvider(currentUser: AuthUser(id: "user-123", email: "demo@kidstrack.app"))
        let viewModel = CreateFamilyViewModel(
            createFamilyUseCase: CreateFamilyUseCase(repository: repository, activeStore: store),
            sessionProvider: session
        )
        return (viewModel, repository, store)
    }
}
