import Domain
import Foundation
import Presentation
import Shared
import Testing

@MainActor
@Suite("CreateChildViewModel")
struct CreateChildViewModelTests {
    @Test("Requires non-empty name")
    func validatesName() {
        let family = Family(id: "fam", name: "Fam", ownerId: "owner")
        let repository = MockChildrenRepository(mode: .succeed(Child(id: "id", familyId: family.id, name: "Test")))
        let viewModel = CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: repository)
        )

        #expect(viewModel.isFormValid == false)
        viewModel.name = "Ana"
        #expect(viewModel.isFormValid)
    }

    @Test("Submits request with optional fields")
    func submitsChild() async throws {
        let family = Family(id: "fam", name: "Fam", ownerId: "owner")
        let expected = Child(
            id: "child-1",
            familyId: family.id,
            name: "Bruno",
            birthDate: .now,
            grade: "2B",
            colorHex: "#1ABC9C"
        )
        let repository = MockChildrenRepository(mode: .succeed(expected))
        let viewModel = CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: repository)
        )

        viewModel.name = expected.name
        viewModel.includeBirthDate = true
        viewModel.birthDate = expected.birthDate ?? Date()
        viewModel.grade = expected.grade ?? ""
        viewModel.selectedColorHex = expected.colorHex

        var created: Child?
        viewModel.submit { child in
            created = child
        }

        try await waitUntil { created != nil }
        #expect(repository.callCount == 1)
        #expect(created == expected)
        #expect(repository.receivedCreateRequest?.colorHex == expected.colorHex)
        #expect(repository.receivedCreateRequest?.grade == expected.grade)
        #expect(repository.receivedCreateRequest?.birthDate != nil)
    }

    @Test("Surfaces errors on failure")
    func handlesError() async throws {
        enum SampleError: Error { case failure }
        let family = Family(id: "fam", name: "Fam", ownerId: "owner")
        let repository = MockChildrenRepository(mode: .fail(SampleError.failure))
        let viewModel = CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: repository)
        )

        viewModel.name = "Alex"
        viewModel.submit { _ in }

        try await waitUntil { viewModel.error != nil }
        #expect(viewModel.isSubmitting == false)
    }

    @Test("Updates existing child when editing")
    func updatesChild() async throws {
        let family = Family(id: "fam", name: "Fam", ownerId: "owner")
        let existing = Child(id: "child-1", familyId: family.id, name: "Bruno", birthDate: Date(), grade: "2B", colorHex: "#1ABC9C")
        let repository = MockChildrenRepository(mode: .succeed(existing))
        let viewModel = CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: repository),
            updateChild: UpdateChildUseCase(repository: repository),
            existingChild: existing
        )

        #expect(viewModel.isEditing)
        #expect(viewModel.name == existing.name)

        viewModel.name = "Bruno Jr."
        var saved: Child?
        viewModel.submit { child in
            saved = child
        }

        try await waitUntil { saved != nil }
        #expect(repository.callCount == 1)
        #expect(repository.receivedUpdateRequest?.id == existing.id)
        #expect(repository.receivedUpdateRequest?.name == "Bruno Jr.")
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

    throw CreateChildWaitError.timeout
}

enum CreateChildWaitError: Error {
    case timeout
}
