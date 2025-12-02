import Shared

public protocol ChildrenRepositoryProtocol: Sendable {
    func createChild(_ request: CreateChildRequest) async throws -> Child
    func updateChild(_ request: UpdateChildRequest) async throws -> Child
}
