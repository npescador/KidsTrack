import Shared

public protocol InvitationRepositoryProtocol: Sendable {
    func sendInvitation(familyId: String, email: String) async throws -> FamilyInvitation
}
