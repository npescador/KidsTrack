import Foundation
import Shared

public final class InMemoryFamiliesRemoteDataSource: FamiliesRemoteDataSourceProtocol, @unchecked Sendable {
    private var familiesByUser: [String: [Family]] = [:]
    private var familiesById: [String: Family] = [:]

    public init() {}

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        let id = UUID().uuidString
        let family = Family(id: id, name: name, ownerId: ownerId, createdAt: Date())
        var families = familiesByUser[ownerId, default: []]
        families.append(family)
        familiesByUser[ownerId] = families
        familiesById[id] = family
        return family
    }

    public func fetchFamilies(for userId: String) async throws -> [Family] {
        familiesByUser[userId, default: []]
    }

    public func addFamily(_ family: Family, for userId: String) async throws {
        var families = familiesByUser[userId, default: []]
        if !families.contains(where: { $0.id == family.id }) {
            families.append(family)
        }
        familiesByUser[userId] = families
        familiesById[family.id] = family
    }
}
