import Foundation

public struct Expense: Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let childId: String
    public let activityId: String?
    public let amount: Double
    public let concept: String
    public let date: Date

    public init(
        id: String,
        childId: String,
        activityId: String? = nil,
        amount: Double,
        concept: String,
        date: Date
    ) {
        self.id = id
        self.childId = childId
        self.activityId = activityId
        self.amount = amount
        self.concept = concept
        self.date = date
    }
}
