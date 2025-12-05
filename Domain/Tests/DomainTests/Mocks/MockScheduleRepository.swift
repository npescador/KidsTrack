import Domain
import Shared

final class MockScheduleRepository: SchoolScheduleRepositoryProtocol, @unchecked Sendable {
    var createdRequest: CreateSchoolSlotRequest?
    var updatedRequest: UpdateSchoolSlotRequest?
    var deleteCalls: [(String, String)] = []
    var slotToReturn: SchoolSlot?

    func createSchoolSlot(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot {
        createdRequest = request
        return slotToReturn ?? SchoolSlot(
            id: "slot-1",
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )
    }

    func updateSchoolSlot(_ request: UpdateSchoolSlotRequest) async throws -> SchoolSlot {
        updatedRequest = request
        return slotToReturn ?? SchoolSlot(
            id: request.id,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )
    }

    func deleteSchoolSlot(id: String, familyId: String) async throws {
        deleteCalls.append((id, familyId))
    }
}
