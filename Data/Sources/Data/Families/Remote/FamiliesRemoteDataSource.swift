import Shared

public protocol FamiliesRemoteDataSourceProtocol: Sendable {
    func createFamily(name: String, ownerId: String) async throws -> Family
}
