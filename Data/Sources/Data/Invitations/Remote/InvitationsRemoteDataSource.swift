import Shared

public protocol InvitationsRemoteDataSourceProtocol: Sendable {
    func sendInvitation(family: Family, email: String) async throws -> FamilyInvitation
    func fetchInvitations(for email: String) async throws -> [FamilyInvitation]
    func acceptInvitation(id: String, userId: String) async throws -> Family
    func rejectInvitation(id: String) async throws
}
