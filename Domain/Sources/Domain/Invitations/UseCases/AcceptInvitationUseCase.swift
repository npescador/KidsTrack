import Shared

public struct AcceptInvitationUseCase: Sendable {
    private let repository: InvitationRepositoryProtocol
    private let familyRepository: FamilyRepositoryProtocol

    public init(repository: InvitationRepositoryProtocol, familyRepository: FamilyRepositoryProtocol) {
        self.repository = repository
        self.familyRepository = familyRepository
    }

    public func execute(invitationId: String, userId: String) async throws -> Family {
        let family = try await repository.acceptInvitation(id: invitationId, userId: userId)
        try await familyRepository.addFamily(family, for: userId)
        return family
    }
}
