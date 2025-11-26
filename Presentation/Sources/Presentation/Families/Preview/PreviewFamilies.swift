import Domain
import Foundation
import Shared

#if DEBUG
public struct PreviewFamilyRepository: FamilyRepositoryProtocol {
    public init() {}

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        Family(id: UUID().uuidString, name: name, ownerId: ownerId)
    }
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
#endif
