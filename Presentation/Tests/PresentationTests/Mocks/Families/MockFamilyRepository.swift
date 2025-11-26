import Domain
import Shared

final class MockFamilyRepository: FamilyRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<Family, Error> = .success(.init(id: "fam-1", name: "Test", ownerId: "owner"))
    var fetchResult: Result<[Family], Error> = .success([])
    var receivedName: String?
    var receivedOwnerId: String?
    var receivedFetchUserId: String?

    func createFamily(name: String, ownerId: String) async throws -> Family {
        receivedName = name
        receivedOwnerId = ownerId
        return try nextResult.get()
    }

    func fetchFamilies(for userId: String) async throws -> [Family] {
        receivedFetchUserId = userId
        switch fetchResult {
        case .success(let families):
            return families
        case .failure(let error):
            throw error
        }
    }
}
