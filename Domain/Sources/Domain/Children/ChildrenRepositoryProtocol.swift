import Shared

public protocol ChildrenRepositoryProtocol: Sendable {
    func createChild(_ request: CreateChildRequest) async throws -> Child
}
