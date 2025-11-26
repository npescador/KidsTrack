import Foundation
import Shared

public final class InMemoryFamiliesRemoteDataSource: FamiliesRemoteDataSourceProtocol, @unchecked Sendable {
    private var familiesByUser: [String: [Family]] = [:]

    public init() {}

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        let id = UUID().uuidString
        let family = Family(id: id, name: name, ownerId: ownerId, createdAt: Date())
        var families = familiesByUser[ownerId, default: []]
        families.append(family)
        familiesByUser[ownerId] = families
        return family
    }

    public func fetchFamilies(for userId: String) async throws -> [Family] {
        familiesByUser[userId, default: []]
    }
}
