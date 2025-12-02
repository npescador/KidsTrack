import Domain
import Shared

public protocol ChildrenRemoteDataSourceProtocol: Sendable {
    func createChild(_ request: CreateChildRequest) async throws -> Child
}
