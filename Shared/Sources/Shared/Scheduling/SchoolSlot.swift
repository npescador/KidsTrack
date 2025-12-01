import Foundation

public struct SchoolSlot: Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let childId: String
    public let weekday: Weekday
    public let startTime: DateComponents
    public let endTime: DateComponents
    public let subject: String
    public let room: String?

    public init(
        id: String,
        childId: String,
        weekday: Weekday,
        startTime: DateComponents,
        endTime: DateComponents,
        subject: String,
        room: String? = nil
    ) {
        self.id = id
        self.childId = childId
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.subject = subject
        self.room = room
    }
}
