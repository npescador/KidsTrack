import Shared

public struct GetPendingInvitationsUseCase: Sendable {
    private let repository: InvitationRepositoryProtocol

    public init(repository: InvitationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(email: String) async throws -> [FamilyInvitation] {
        try await repository.fetchInvitations(for: email)
    }
}
