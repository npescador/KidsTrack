import Domain
import Shared

public final class FamiliesRepository: FamilyRepositoryProtocol, @unchecked Sendable {
    private let remoteDataSource: FamiliesRemoteDataSourceProtocol

    public init(remoteDataSource: FamiliesRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        try await remoteDataSource.createFamily(name: name, ownerId: ownerId)
    }
}
