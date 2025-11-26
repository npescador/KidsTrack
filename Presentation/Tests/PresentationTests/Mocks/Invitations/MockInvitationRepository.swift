import Domain
import Shared

final class MockInvitationRepository: InvitationRepositoryProtocol, @unchecked Sendable {
    var nextResult: Result<FamilyInvitation, Error> = .success(
        FamilyInvitation(id: "inv-1", familyId: "fam-1", email: "test@kidstrack.app")
    )
    var sentFamilyId: String?
    var sentEmail: String?

    func sendInvitation(familyId: String, email: String) async throws -> FamilyInvitation {
        sentFamilyId = familyId
        sentEmail = email
        return try nextResult.get()
    }
}
