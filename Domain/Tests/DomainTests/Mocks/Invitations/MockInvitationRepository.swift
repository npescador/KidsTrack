import Domain
import Shared
import Testing

final class MockInvitationRepository: InvitationRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<FamilyInvitation, Error>?
    var sentFamilyId: String?
    var sentEmail: String?

    func sendInvitation(family: Family, email: String) async throws -> FamilyInvitation {
        sentFamilyId = family.id
        sentEmail = email
        guard let nextResult else {
            Issue.record("nextResult must be set before invoking sendInvitation")
            throw InvitationError.unknown(message: "Missing stub")
        }
        return try nextResult.get()
    }

    func fetchInvitations(for email: String) async throws -> [FamilyInvitation] {
        []
    }

    func acceptInvitation(id: String, userId: String) async throws -> Family {
        Family(id: "fam-accepted", name: "Accepted", ownerId: "owner")
    }

    func rejectInvitation(id: String) async throws {}
}
