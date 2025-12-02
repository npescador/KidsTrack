import Foundation

public enum ActivityCategory: String, Codable, Equatable, Sendable {
    case sport
    case music
    case languages
    case other
}

public enum Recurrence: String, Codable, Equatable, Sendable {
    case monthly
    case quarterly
    case yearly
}

public struct Activity: Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let childId: String
    public let name: String
    public let category: ActivityCategory
    public let weekdays: [Weekday]
    public let startTime: DateComponents
    public let endTime: DateComponents
    public let location: String?
    public let recurringCost: Double?
    public let recurrence: Recurrence?

    public init(
        id: String,
        childId: String,
        name: String,
        category: ActivityCategory,
        weekdays: [Weekday],
        startTime: DateComponents,
        endTime: DateComponents,
        location: String? = nil,
        recurringCost: Double? = nil,
        recurrence: Recurrence? = nil
    ) {
        self.id = id
        self.childId = childId
        self.name = name
        self.category = category
        self.weekdays = weekdays
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.recurringCost = recurringCost
        self.recurrence = recurrence
    }
}
