import Domain
import Foundation
import Presentation
import Shared
import Testing

@MainActor
@Suite("FamilyRealtimeSyncCoordinator")
struct FamilyRealtimeSyncCoordinatorTests {
    @Test("Starts streaming for selected family and updates snapshot")
    func streamsUpdates() async throws {
        let system = makeSystem()
        system.coordinator.switchFamily(to: "fam1")

        try await waitUntil { system.repository.continuation(for: "fam1")?.children != nil }

        let child = Child(id: "c1", familyId: "fam1", name: "Alex")
        let activity = Activity(
            id: "a1",
            childId: "c1",
            name: "Piano",
            category: .music,
            weekdays: [.monday],
            startTime: .init(hour: 17, minute: 0),
            endTime: .init(hour: 18, minute: 0)
        )
        let expense = Expense(id: "e1", childId: "c1", amount: 25, concept: "Book", date: Date())

        system.repository.continuation(for: "fam1")?.children?.yield([child])
        system.repository.continuation(for: "fam1")?.activities?.yield([activity])
        system.repository.continuation(for: "fam1")?.expenses?.yield([expense])

        try await waitUntil {
            system.coordinator.snapshot.children == [child] &&
                system.coordinator.snapshot.activities == [activity] &&
                system.coordinator.snapshot.expenses == [expense]
        }
    }

    @Test("Switching family clears old listeners and ignores stale updates")
    func switchesFamily() async throws {
        let system = makeSystem()
        system.coordinator.switchFamily(to: "famA")
        try await waitUntil { system.repository.continuation(for: "famA")?.children != nil }

        let childA = Child(id: "cA", familyId: "famA", name: "Ana")
        system.repository.continuation(for: "famA")?.children?.yield([childA])
        try await waitUntil { system.coordinator.snapshot.children == [childA] }

        system.coordinator.switchFamily(to: "famB")
        try await waitUntil { system.repository.continuation(for: "famB")?.children != nil }

        let childB = Child(id: "cB", familyId: "famB", name: "Biel")
        system.repository.continuation(for: "famB")?.children?.yield([childB])
        try await waitUntil { system.coordinator.snapshot.children == [childB] }

        system.repository.continuation(for: "famA")?.children?.yield(
            [Child(
                id: "stale",
                familyId: "famA",
                name: "Stale"
            )]
        )
        try await Task.sleep(nanoseconds: 20_000_000)

        #expect(system.coordinator.snapshot.children == [childB])
    }

    @Test("Restart reattaches to current family and clears stale snapshot")
    func restartsExistingFamily() async throws {
        let system = makeSystem()
        system.coordinator.switchFamily(to: "famX")
        try await waitUntil { system.repository.continuation(for: "famX")?.children != nil }

        let first = Child(id: "first", familyId: "famX", name: "First")
        system.repository.continuation(for: "famX")?.children?.yield([first])
        try await waitUntil { system.coordinator.snapshot.children == [first] }

        system.coordinator.restart()
        try await waitUntil { system.repository.continuation(for: "famX")?.children != nil }

        #expect(system.coordinator.snapshot.children == [first])

        let refreshed = Child(id: "refreshed", familyId: "famX", name: "Refreshed")
        system.repository.continuation(for: "famX")?.children?.yield([refreshed])
        try await waitUntil { system.coordinator.snapshot.children == [refreshed] }
    }

    @Test("Deduplicates updates by id")
    func deduplicatesById() async throws {
        let system = makeSystem()
        system.coordinator.switchFamily(to: "famDedupe")
        try await waitUntil { system.repository.continuation(for: "famDedupe")?.children != nil }

        let first = Child(id: "dup", familyId: "famDedupe", name: "Kid")
        system.repository.continuation(for: "famDedupe")?.children?.yield([first, first])

        try await waitUntil { system.coordinator.snapshot.children.count == 1 }
    }

    @Test("Stop clears snapshot and ignores further updates")
    func stopsStreaming() async throws {
        let system = makeSystem()
        system.coordinator.switchFamily(to: "famStop")
        try await waitUntil { system.repository.continuation(for: "famStop")?.children != nil }

        let first = Child(id: "cStop", familyId: "famStop", name: "Stop")
        system.repository.continuation(for: "famStop")?.children?.yield([first])
        try await waitUntil { system.coordinator.snapshot.children == [first] }

        system.coordinator.stop()
        #expect(system.coordinator.snapshot == .empty)

        let stale = Child(id: "stale", familyId: "famStop", name: "Stale")
        system.repository.continuation(for: "famStop")?.children?.yield([stale])
        try await Task.sleep(nanoseconds: 20_000_000)
        #expect(system.coordinator.snapshot.children.isEmpty)
    }
}

private extension FamilyRealtimeSyncCoordinatorTests {
    struct System {
        let coordinator: FamilyRealtimeSyncCoordinator
        let repository: MockFamilyRealtimeRepository
    }

    func makeSystem() -> System {
        let repository = MockFamilyRealtimeRepository()
        let observe = ObserveFamilyRealtimeUseCase(repository: repository)
        let coordinator = FamilyRealtimeSyncCoordinator(observeRealtime: observe)
        return System(coordinator: coordinator, repository: repository)
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

    throw RealtimeWaitError.timeout
}

enum RealtimeWaitError: Error {
    case timeout
}
