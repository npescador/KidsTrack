import Domain
import Shared

public final class ScheduleRepository: SchoolScheduleRepositoryProtocol, @unchecked Sendable {
    private let remote: ScheduleRemoteDataSourceProtocol

    public init(remote: ScheduleRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func createSchoolSlot(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot {
        try await remote.createSchoolSlot(request)
    }

    public func updateSchoolSlot(_ request: UpdateSchoolSlotRequest) async throws -> SchoolSlot {
        try await remote.updateSchoolSlot(request)
    }

    public func deleteSchoolSlot(id: String, familyId: String) async throws {
        try await remote.deleteSchoolSlot(id: id, familyId: familyId)
    }
}
