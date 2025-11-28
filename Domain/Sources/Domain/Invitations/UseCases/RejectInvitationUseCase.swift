public struct RejectInvitationUseCase: Sendable {
    private let repository: InvitationRepositoryProtocol

    public init(repository: InvitationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(invitationId: String) async throws {
        try await repository.rejectInvitation(id: invitationId)
    }
}
