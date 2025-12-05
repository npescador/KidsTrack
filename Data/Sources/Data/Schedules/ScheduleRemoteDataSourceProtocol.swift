import Domain
import Shared

public protocol ScheduleRemoteDataSourceProtocol: Sendable {
    func createSchoolSlot(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot
    func updateSchoolSlot(_ request: UpdateSchoolSlotRequest) async throws -> SchoolSlot
    func deleteSchoolSlot(id: String, familyId: String) async throws
}
