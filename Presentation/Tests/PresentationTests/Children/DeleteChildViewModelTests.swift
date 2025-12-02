import Domain
import Presentation
import Shared
import Testing

@MainActor
@Suite("DeleteChildViewModel")
struct DeleteChildViewModelTests {
    @Test("Deletes child successfully")
    func deletesChild() async throws {
        let family = Family(id: "fam", name: "Fam", ownerId: "owner")
        let child = Child(id: "child", familyId: "fam", name: "Alex")
        let repository = MockChildrenRepository(mode: .succeed(child))
        let viewModel = DeleteChildViewModel(
            family: family,
            child: child,
            deleteChild: DeleteChildUseCase(repository: repository)
        )

        var deleted = false
        viewModel.delete {
            deleted = true
        }

        try await waitUntil { deleted }
        #expect(repository.receivedUpdateRequest == nil)
        #expect(repository.callCount == 1)
    }

    @Test("Surfaces error on failure")
    func handlesError() async throws {
        enum SampleError: Error { case failure }
        let family = Family(id: "fam", name: "Fam", ownerId: "owner")
        let child = Child(id: "child", familyId: "fam", name: "Alex")
        let repository = MockChildrenRepository(mode: .fail(SampleError.failure))
        let viewModel = DeleteChildViewModel(
            family: family,
            child: child,
            deleteChild: DeleteChildUseCase(repository: repository)
        )

        viewModel.delete {}
        try await waitUntil { viewModel.error != nil }
        #expect(viewModel.isDeleting == false)
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

    throw DeleteChildWaitError.timeout
}

enum DeleteChildWaitError: Error {
    case timeout
}
