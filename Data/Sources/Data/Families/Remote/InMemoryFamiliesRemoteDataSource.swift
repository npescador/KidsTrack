import Foundation
import Shared

public final class InMemoryFamiliesRemoteDataSource: FamiliesRemoteDataSourceProtocol, @unchecked Sendable {
    private var families: [String: Family] = [:]

    public init() {}

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        let id = UUID().uuidString
        let family = Family(id: id, name: name, ownerId: ownerId, createdAt: Date())
        families[id] = family
        return family
    }
}
