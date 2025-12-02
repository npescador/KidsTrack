import Domain
import Shared

final class MockFamilyRealtimeRepository: FamilyRealtimeRepositoryProtocol {
    struct Continuations {
        var children: AsyncStream<[Child]>.Continuation?
        var schoolSlots: AsyncStream<[SchoolSlot]>.Continuation?
        var activities: AsyncStream<[Activity]>.Continuation?
        var expenses: AsyncStream<[Expense]>.Continuation?
    }

    private(set) var continuationsByFamily: [String: Continuations] = [:]

    func observeChildren(for familyId: String) -> AsyncStream<[Child]> {
        makeStream(for: familyId, keyPath: \.children)
    }

    func observeSchoolSlots(for familyId: String) -> AsyncStream<[SchoolSlot]> {
        makeStream(for: familyId, keyPath: \.schoolSlots)
    }

    func observeActivities(for familyId: String) -> AsyncStream<[Activity]> {
        makeStream(for: familyId, keyPath: \.activities)
    }

    func observeExpenses(for familyId: String) -> AsyncStream<[Expense]> {
        makeStream(for: familyId, keyPath: \.expenses)
    }

    func continuation(for familyId: String) -> Continuations? {
        continuationsByFamily[familyId]
    }
}

private extension MockFamilyRealtimeRepository {
    func makeStream<Value>(
        for familyId: String,
        keyPath: WritableKeyPath<Continuations, AsyncStream<[Value]>.Continuation?>
    ) -> AsyncStream<[Value]> {
        AsyncStream { continuation in
            var stored = continuationsByFamily[familyId, default: Continuations()]
            stored[keyPath: keyPath] = continuation
            continuationsByFamily[familyId] = stored
        }
    }
}
