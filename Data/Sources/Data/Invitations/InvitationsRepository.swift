import Domain
import Shared

public final class InvitationsRepository: InvitationRepositoryProtocol, @unchecked Sendable {
    private let remote: InvitationsRemoteDataSourceProtocol

    public init(remote: InvitationsRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func sendInvitation(familyId: String, email: String) async throws -> FamilyInvitation {
        try await remote.sendInvitation(familyId: familyId, email: email)
    }
}
