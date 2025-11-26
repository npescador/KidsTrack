import Shared

public protocol FamiliesRemoteDataSourceProtocol: Sendable {
    func createFamily(name: String, ownerId: String) async throws -> Family
    func fetchFamilies(for userId: String) async throws -> [Family]
    func addFamily(_ family: Family, for userId: String) async throws
}
