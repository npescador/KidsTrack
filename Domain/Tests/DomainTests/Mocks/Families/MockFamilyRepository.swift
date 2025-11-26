import Domain
import Shared
import Testing

public enum MockFamilyRepositoryError: Error {
    case missingResult
}

final class MockFamilyRepository: FamilyRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<Family, Error>?
    var fetchResult: Result<[Family], Error> = .success([])
    var receivedName: String?
    var receivedOwnerId: String?

    var receivedFetchUserId: String?

    func createFamily(name: String, ownerId: String) async throws -> Family {
        receivedName = name
        receivedOwnerId = ownerId
        guard let nextResult else {
            Issue.record("nextResult must be set before invoking createFamily")
            throw MockFamilyRepositoryError.missingResult
        }
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
