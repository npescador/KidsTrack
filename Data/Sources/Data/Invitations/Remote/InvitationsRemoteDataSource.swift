import Shared

public protocol InvitationsRemoteDataSourceProtocol: Sendable {
    func sendInvitation(familyId: String, email: String) async throws -> FamilyInvitation
}
