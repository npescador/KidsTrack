import Foundation

/// Represents a family grouping within the app.
public struct Family: Codable, Hashable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let ownerId: String
    public let createdAt: Date

    public init(
        id: String,
        name: String,
        ownerId: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.createdAt = createdAt
    }
}
