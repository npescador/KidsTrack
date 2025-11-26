import Domain
import Foundation
import Shared

#if DEBUG
public struct PreviewFamilyRepository: FamilyRepositoryProtocol {
    public init() {}

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        Family(id: UUID().uuidString, name: name, ownerId: ownerId)
    }

    public func fetchFamilies(for userId: String) async throws -> [Family] {
        [
            Family(id: "preview-1", name: "Preview Family", ownerId: userId)
        ]
    }

    public func addFamily(_ family: Family, for userId: String) async throws {}
}

public struct PreviewActiveFamilyStore: ActiveFamilyStoreProtocol {
    public init() {}

    public func setActiveFamily(_ family: Family) async {}
    public func activeFamily() async -> Family? { nil }
    public func clearActiveFamily() async {}
}

public struct PreviewUserSessionProvider: UserSessionProviding {
    public let currentUser: AuthUser?

    public init(currentUser: AuthUser? = .init(id: "preview-owner", email: "demo@kidstrack.app")) {
        self.currentUser = currentUser
    }
}

public struct PreviewInvitationRepository: InvitationRepositoryProtocol {
    public init() {}

    public func sendInvitation(family: Family, email: String) async throws -> FamilyInvitation {
        FamilyInvitation(id: UUID().uuidString, familyId: family.id, familyName: family.name, email: email)
    }

    public func fetchInvitations(for email: String) async throws -> [FamilyInvitation] { [] }
    public func acceptInvitation(id: String, userId: String) async throws -> Family {
        Family(id: "inv-\(id)", name: "Preview Invited Family", ownerId: "preview-owner")
    }
    public func rejectInvitation(id: String) async throws {}
}
#endif
