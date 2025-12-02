import Shared

public struct FamilyRealtimeStreams: Sendable {
    public let children: AsyncStream<[Child]>
    public let schoolSlots: AsyncStream<[SchoolSlot]>
    public let activities: AsyncStream<[Activity]>
    public let expenses: AsyncStream<[Expense]>

    public init(
        children: AsyncStream<[Child]>,
        schoolSlots: AsyncStream<[SchoolSlot]>,
        activities: AsyncStream<[Activity]>,
        expenses: AsyncStream<[Expense]>
    ) {
        self.children = children
        self.schoolSlots = schoolSlots
        self.activities = activities
        self.expenses = expenses
    }
}

public struct ObserveFamilyRealtimeUseCase: Sendable {
    private let repository: FamilyRealtimeRepositoryProtocol

    public init(repository: FamilyRealtimeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(familyId: String) -> FamilyRealtimeStreams {
        FamilyRealtimeStreams(
            children: repository.observeChildren(for: familyId),
            schoolSlots: repository.observeSchoolSlots(for: familyId),
            activities: repository.observeActivities(for: familyId),
            expenses: repository.observeExpenses(for: familyId)
        )
    }
}
