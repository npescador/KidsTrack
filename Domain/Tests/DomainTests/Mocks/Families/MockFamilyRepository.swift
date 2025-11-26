import Domain
import Shared
import Testing

enum MockFamilyRepositoryError: Error {
    case missingResult
}

final class MockFamilyRepository: FamilyRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<Family, Error>?
    var receivedName: String?
    var receivedOwnerId: String?

    func createFamily(name: String, ownerId: String) async throws -> Family {
        receivedName = name
        receivedOwnerId = ownerId
        guard let nextResult else {
            Issue.record("nextResult must be set before invoking createFamily")
            throw MockFamilyRepositoryError.missingResult
        }
        return try nextResult.get()
    }
}
