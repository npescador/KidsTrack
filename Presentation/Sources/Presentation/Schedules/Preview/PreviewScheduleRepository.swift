import Domain
import Foundation
import Shared

public struct PreviewScheduleRepository: SchoolScheduleRepositoryProtocol {
    public init() {}

    public func createSchoolSlot(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot {
        SchoolSlot(
            id: UUID().uuidString,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )
    }

    public func updateSchoolSlot(_ request: UpdateSchoolSlotRequest) async throws -> SchoolSlot {
        SchoolSlot(
            id: request.id,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )
    }

    public func deleteSchoolSlot(id: String, familyId: String) async throws {}
}
