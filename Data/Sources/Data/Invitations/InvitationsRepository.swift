import Domain
import Shared

public final class InvitationsRepository: InvitationRepositoryProtocol, @unchecked Sendable {
    private let remote: InvitationsRemoteDataSourceProtocol

    public init(remote: InvitationsRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func sendInvitation(family: Family, email: String) async throws -> FamilyInvitation {
        try await remote.sendInvitation(family: family, email: email)
    }

    public func fetchInvitations(for email: String) async throws -> [FamilyInvitation] {
        try await remote.fetchInvitations(for: email)
    }

    public func acceptInvitation(id: String, userId: String) async throws -> Family {
        try await remote.acceptInvitation(id: id, userId: userId)
    }

    public func rejectInvitation(id: String) async throws {
        try await remote.rejectInvitation(id: id)
    }
}
