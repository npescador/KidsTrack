import Foundation
import Shared

public struct CreateSchoolSlotUseCase: Sendable {
    private let repository: SchoolScheduleRepositoryProtocol
    private let calendar: Calendar

    public init(repository: SchoolScheduleRepositoryProtocol, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }

    public func execute(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot {
        try validate(request)
        let trimmedSubject = request.subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedRoom = request.room?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let normalizedRequest = CreateSchoolSlotRequest(
            familyId: request.familyId,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: trimmedSubject,
            room: normalizedRoom
        )
        return try await repository.createSchoolSlot(normalizedRequest)
    }
}

private extension CreateSchoolSlotUseCase {
    func validate(_ request: CreateSchoolSlotRequest) throws {
        if request.childId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SchoolSlotValidationError.missingChild
        }
        if request.subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SchoolSlotValidationError.emptySubject
        }
        guard let startDate = merge(request.startTime, with: Date()),
              let endDate = merge(request.endTime, with: Date()),
              startDate < endDate else {
            throw SchoolSlotValidationError.invalidTimeRange
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension CreateSchoolSlotUseCase {
    func merge(_ components: DateComponents, with baseDate: Date) -> Date? {
        var merged = components
        let dateParts = calendar.dateComponents([.year, .month, .day], from: baseDate)
        merged.year = dateParts.year
        merged.month = dateParts.month
        merged.day = dateParts.day
        return calendar.date(from: merged)
    }
}
