import Foundation

public struct FamilyRealtimeSnapshot: Equatable, Sendable {
    public var children: [Child]
    public var schoolSlots: [SchoolSlot]
    public var activities: [Activity]
    public var expenses: [Expense]

    public init(
        children: [Child] = [],
        schoolSlots: [SchoolSlot] = [],
        activities: [Activity] = [],
        expenses: [Expense] = []
    ) {
        self.children = children
        self.schoolSlots = schoolSlots
        self.activities = activities
        self.expenses = expenses
    }

    public static let empty = FamilyRealtimeSnapshot()
}
