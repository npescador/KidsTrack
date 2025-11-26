import Domain
import Shared
import Testing

final class MockInvitationRepository: InvitationRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<FamilyInvitation, Error>?
    var sentFamilyId: String?
    var sentEmail: String?

    func sendInvitation(familyId: String, email: String) async throws -> FamilyInvitation {
        sentFamilyId = familyId
        sentEmail = email
        guard let nextResult else {
            Issue.record("nextResult must be set before invoking sendInvitation")
            throw InvitationError.unknown(message: "Missing stub")
        }
        return try nextResult.get()
    }
}
