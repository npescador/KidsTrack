import Shared

public struct SendFamilyInvitationUseCase: Sendable {
    private let repository: InvitationRepositoryProtocol

    public init(repository: InvitationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(family: Family, email: String) async throws -> FamilyInvitation {
        try await repository.sendInvitation(family: family, email: email)
    }
}
