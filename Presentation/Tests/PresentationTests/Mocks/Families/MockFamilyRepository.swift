import Domain
import Shared

final class MockFamilyRepository: FamilyRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<Family, Error> = .success(.init(id: "fam-1", name: "Test", ownerId: "owner"))
    var receivedName: String?
    var receivedOwnerId: String?

    func createFamily(name: String, ownerId: String) async throws -> Family {
        receivedName = name
        receivedOwnerId = ownerId
        return try nextResult.get()
    }
}
