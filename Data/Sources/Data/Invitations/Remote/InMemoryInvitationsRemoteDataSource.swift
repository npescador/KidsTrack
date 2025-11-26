import Foundation
import Shared

public final class InMemoryInvitationsRemoteDataSource: InvitationsRemoteDataSourceProtocol, @unchecked Sendable {
    private var invitationsByFamily: [String: [FamilyInvitation]] = [:]

    public init() {}

    public func sendInvitation(familyId: String, email: String) async throws -> FamilyInvitation {
        let normalizedEmail = email.lowercased()
        let existing = invitationsByFamily[familyId, default: []]
        if existing.contains(where: { $0.email.lowercased() == normalizedEmail && $0.status == .pending }) {
            throw InvitationError.duplicatePending
        }

        let invitation = FamilyInvitation(
            id: UUID().uuidString,
            familyId: familyId,
            email: normalizedEmail,
            status: .pending,
            createdAt: Date()
        )
        var updated = existing
        updated.append(invitation)
        invitationsByFamily[familyId] = updated
        return invitation
    }
}
