import Foundation

public enum SchoolSlotValidationError: LocalizedError, Sendable, Equatable {
    case missingChild
    case emptySubject
    case invalidTimeRange

    public var errorDescription: String? {
        switch self {
        case .missingChild:
            return "schoolSlot.error.child.missing"
        case .emptySubject:
            return "schoolSlot.error.subject.empty"
        case .invalidTimeRange:
            return "schoolSlot.error.timerange.invalid"
        }
    }
}
