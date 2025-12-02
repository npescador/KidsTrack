import Presentation
import Shared
import Testing

@MainActor
@Suite("ChildrenListViewModel")
struct ChildrenListViewModelTests {
    @Test("Streams children from realtime snapshot")
    func streamsChildren() async throws {
        let family = Family(id: "fam-1", name: "Home", ownerId: "owner")
        let syncer = MockFamilyRealtimeSyncer()
        let viewModel = ChildrenListViewModel(activeFamily: family)

        viewModel.start(using: syncer)

        let child = Child(id: "kid-1", familyId: family.id, name: "Alex", grade: "2B")
        syncer.emit(FamilyRealtimeSnapshot(children: [child]))

        try await waitUntil { viewModel.state == .loaded([child]) }
        #expect(viewModel.familyName == family.name)
    }

    @Test("Filters children by active family and resets when family changes")
    func switchesFamilies() async throws {
        let firstFamily = Family(id: "fam-A", name: "Alpha", ownerId: "owner")
        let syncer = MockFamilyRealtimeSyncer()
        let viewModel = ChildrenListViewModel(activeFamily: firstFamily)
        viewModel.start(using: syncer)

        let alphaChild = Child(id: "kid-A", familyId: firstFamily.id, name: "Ana")
        syncer.emit(FamilyRealtimeSnapshot(children: [alphaChild]))
        try await waitUntil { viewModel.state == .loaded([alphaChild]) }

        let secondFamily = Family(id: "fam-B", name: "Beta", ownerId: "owner")
        viewModel.updateActiveFamily(secondFamily)

        let betaChild = Child(id: "kid-B", familyId: secondFamily.id, name: "Biel")
        syncer.emit(FamilyRealtimeSnapshot(children: [alphaChild, betaChild]))

        try await waitUntil { viewModel.state == .loaded([betaChild]) }
        #expect(viewModel.familyName == secondFamily.name)
    }

    @Test("Falls back to no-family state when there is no active family")
    func handlesMissingFamily() async {
        let viewModel = ChildrenListViewModel(activeFamily: nil)
        viewModel.start(using: nil)
        #expect(viewModel.state == .noFamily)
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

    throw ChildrenWaitError.timeout
}

enum ChildrenWaitError: Error {
    case timeout
}
