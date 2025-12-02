import Domain
import Shared

public final class FamilyRealtimeRepository: FamilyRealtimeRepositoryProtocol, @unchecked Sendable {
    private let remote: FamilyRealtimeRemoteDataSourceProtocol

    public init(remote: FamilyRealtimeRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func observeChildren(for familyId: String) -> AsyncStream<[Child]> {
        remote.observeChildren(for: familyId)
    }

    public func observeSchoolSlots(for familyId: String) -> AsyncStream<[SchoolSlot]> {
        remote.observeSchoolSlots(for: familyId)
    }

    public func observeActivities(for familyId: String) -> AsyncStream<[Activity]> {
        remote.observeActivities(for: familyId)
    }

    public func observeExpenses(for familyId: String) -> AsyncStream<[Expense]> {
        remote.observeExpenses(for: familyId)
    }
}
