import Shared

public protocol FamilyRealtimeRepositoryProtocol: Sendable {
    func observeChildren(for familyId: String) -> AsyncStream<[Child]>
    func observeSchoolSlots(for familyId: String) -> AsyncStream<[SchoolSlot]>
    func observeActivities(for familyId: String) -> AsyncStream<[Activity]>
    func observeExpenses(for familyId: String) -> AsyncStream<[Expense]>
}
