import Foundation

public enum InvitationStatus: String, Codable, Equatable, Sendable {
    case pending
    case accepted
    case rejected
}

public struct FamilyInvitation: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let familyId: String
    public let familyName: String
    public let email: String
    public let status: InvitationStatus
    public let createdAt: Date

    public init(
        id: String,
        familyId: String,
        familyName: String,
        email: String,
        status: InvitationStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.familyId = familyId
        self.familyName = familyName
        self.email = email
        self.status = status
        self.createdAt = createdAt
    }
}
