import Domain
import Shared

final class MockInvitationRepository: InvitationRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<FamilyInvitation, Error> = .success(
        FamilyInvitation(id: "inv-1", familyId: "fam-1", familyName: "Test", email: "test@kidstrack.app")
    )
    var sentFamilyId: String?
    var sentEmail: String?

    func sendInvitation(family: Family, email: String) async throws -> FamilyInvitation {
        sentFamilyId = family.id
        sentEmail = email
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
