import Shared

public protocol FamilyRealtimeRemoteDataSourceProtocol: Sendable {
    func observeChildren(for familyId: String) -> AsyncStream<[Child]>
    func observeSchoolSlots(for familyId: String) -> AsyncStream<[SchoolSlot]>
    func observeActivities(for familyId: String) -> AsyncStream<[Activity]>
    func observeExpenses(for familyId: String) -> AsyncStream<[Expense]>
}
