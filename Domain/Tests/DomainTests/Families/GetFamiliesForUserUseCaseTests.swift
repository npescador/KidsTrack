import Domain
import Shared
import Testing

@Suite("GetFamiliesForUserUseCase")
struct GetFamiliesForUserUseCaseTests {
    @Test("Returns families for the given user")
    func fetchFamiliesSuccess() async throws {
        let repository = MockFamilyRepository()
        let expected = [
            Family(id: "1", name: "Pescador", ownerId: "u1"),
            Family(id: "2", name: "Serrano", ownerId: "u1")
        ]
        repository.fetchResult = .success(expected)
        let useCase = GetFamiliesForUserUseCase(repository: repository)

        let result = try await useCase.execute(userId: "u1")

        #expect(result == expected)
        #expect(repository.receivedFetchUserId == "u1")
    }

    @Test("Bubbles repository errors")
    func fetchFamiliesFailure() async {
        let repository = MockFamilyRepository()
        repository.fetchResult = .failure(MockFamilyRepositoryError.missingResult)
        let useCase = GetFamiliesForUserUseCase(repository: repository)

        do {
            _ = try await useCase.execute(userId: "u1")
            Issue.record("Expected failure")
        } catch {
            #expect(error is MockFamilyRepositoryError)
        }
    }
}
