import Domain
import Shared

public protocol ChildrenRemoteDataSourceProtocol: Sendable {
    func createChild(_ request: CreateChildRequest) async throws -> Child
    func updateChild(_ request: UpdateChildRequest) async throws -> Child
    func deleteChild(id: String, familyId: String) async throws
}
