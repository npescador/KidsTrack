import Foundation
import Shared

public final class InMemoryInvitationsRemoteDataSource: InvitationsRemoteDataSourceProtocol, @unchecked Sendable {
    private var invitationsByFamily: [String: [FamilyInvitation]] = [:]
    private var invitationsByEmail: [String: [FamilyInvitation]] = [:]
    private var invitationsById: [String: FamilyInvitation] = [:]
    private var familiesById: [String: Family] = [:]
    private var memberships: [String: Set<String>] = [:] // familyId -> userIds

    public init() {}

    public func sendInvitation(family: Family, email: String) async throws -> FamilyInvitation {
        let normalizedEmail = email.lowercased()
        let existing = invitationsByFamily[family.id, default: []]
        if existing.contains(where: { $0.email.lowercased() == normalizedEmail && $0.status == .pending }) {
            throw InvitationError.duplicatePending
        }

        let invitation = FamilyInvitation(
            id: UUID().uuidString,
            familyId: family.id,
            familyName: family.name,
            email: normalizedEmail,
            status: .pending,
            createdAt: Date()
        )
        var updated = existing
        updated.append(invitation)
        invitationsByFamily[family.id] = updated
        var byEmail = invitationsByEmail[normalizedEmail, default: []]
        byEmail.append(invitation)
        invitationsByEmail[normalizedEmail] = byEmail
        invitationsById[invitation.id] = invitation
        familiesById[family.id] = family
        return invitation
    }

    public func fetchInvitations(for email: String) async throws -> [FamilyInvitation] {
        let normalized = email.lowercased()
        return invitationsByEmail[normalized, default: []].filter { $0.status == .pending }
    }

    public func acceptInvitation(id: String, userId: String) async throws -> Family {
        guard var invitation = invitationsById[id] else {
            throw InvitationError.notFound
        }
        guard invitation.status == .pending else {
            throw InvitationError.alreadyHandled
        }

        invitation = FamilyInvitation(
            id: invitation.id,
            familyId: invitation.familyId,
            familyName: invitation.familyName,
            email: invitation.email,
            status: .accepted,
            createdAt: invitation.createdAt
        )
        invitationsById[id] = invitation
        updateInvitationCollections(invitation, remove: true)

        guard let family = familiesById[invitation.familyId] else {
            throw InvitationError.unknown(message: "Family not found for invitation.")
        }
        var members = memberships[family.id, default: []]
        members.insert(userId)
        memberships[family.id] = members
        return family
    }

    public func rejectInvitation(id: String) async throws {
        guard var invitation = invitationsById[id] else {
            throw InvitationError.notFound
        }
        guard invitation.status == .pending else {
            throw InvitationError.alreadyHandled
        }
        invitation = FamilyInvitation(
            id: invitation.id,
            familyId: invitation.familyId,
            familyName: invitation.familyName,
            email: invitation.email,
            status: .rejected,
            createdAt: invitation.createdAt
        )
        invitationsById[id] = invitation
        updateInvitationCollections(invitation, remove: true)
    }

    private func updateInvitationCollections(_ invitation: FamilyInvitation, remove: Bool = false) {
        var byFamily = invitationsByFamily[invitation.familyId, default: []]
        if let idx = byFamily.firstIndex(where: { $0.id == invitation.id }) {
            if remove {
                byFamily.remove(at: idx)
            } else {
                byFamily[idx] = invitation
            }
        }
        invitationsByFamily[invitation.familyId] = byFamily

        var byEmail = invitationsByEmail[invitation.email, default: []]
        if let idx = byEmail.firstIndex(where: { $0.id == invitation.id }) {
            if remove {
                byEmail.remove(at: idx)
            } else {
                byEmail[idx] = invitation
            }
        }
        invitationsByEmail[invitation.email] = byEmail
    }
}
