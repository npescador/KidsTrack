import Domain
@testable import Presentation
import Shared
import Testing

@MainActor
@Suite("PasswordResetViewModel")
struct PasswordResetViewModelTests {
    @Test("Shows success banner on reset request")
    func resetSuccess() async throws {
        let (viewModel, repository) = makeSystem()
        repository.resetResult = .success(())

        viewModel.email = "user@test.com"
        viewModel.submit()

        try await waitUntil { viewModel.banner?.style == .success }
        #expect(!viewModel.isLoading)
    }

    @Test("Shows error banner on reset failure")
    func resetFailure() async throws {
        let (viewModel, repository) = makeSystem()
        repository.resetResult = .failure(.network)

        viewModel.email = "user@test.com"
        viewModel.submit()

        try await waitUntil { viewModel.banner?.style == .error }
        #expect(viewModel.banner?.message.contains("server") == true)
    }

    @Test("Blocks invalid email submission")
    func invalidEmail() {
        let (viewModel, repository) = makeSystem()
        viewModel.email = "bad-email"

        viewModel.submit()

        #expect(repository.resetCallCount == 0)
        #expect(viewModel.banner?.style == .error)
    }

    private func makeSystem() -> (PasswordResetViewModel, MockAuthRepository) {
        let repository = MockAuthRepository()
        let viewModel = PasswordResetViewModel(
            resetUseCase: SendPasswordResetUseCase(repository: repository)
        )
        return (viewModel, repository)
    }
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping @MainActor () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while clock.now < deadline {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: 20_000_000)
    }

    throw WaitError.timeout
}
