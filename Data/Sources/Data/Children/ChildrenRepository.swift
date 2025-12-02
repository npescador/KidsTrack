import Domain
import Shared

public final class ChildrenRepository: ChildrenRepositoryProtocol, @unchecked Sendable {
    private let remote: ChildrenRemoteDataSourceProtocol

    public init(remote: ChildrenRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func createChild(_ request: CreateChildRequest) async throws -> Child {
        try await remote.createChild(request)
    }
}
