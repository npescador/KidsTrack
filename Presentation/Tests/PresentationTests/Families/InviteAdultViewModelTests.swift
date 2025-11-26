import Domain
import Presentation
import Shared
import Testing

@MainActor
@Suite("InviteAdultViewModel")
struct InviteAdultViewModelTests {
    @Test("Sends invitation successfully and clears email")
    func sendSuccess() async throws {
        let repository = MockInvitationRepository()
        let viewModel = InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: repository),
            familyId: "fam-1"
        )
        viewModel.email = "adult@test.com"

        viewModel.send()
        try await waitUntil { viewModel.banner != nil }

        #expect(repository.sentFamilyId == "fam-1")
        #expect(repository.sentEmail == "adult@test.com")
        #expect(viewModel.banner?.isError == false)
        #expect(viewModel.email.isEmpty)
    }

    @Test("Invalid email blocks send")
    func invalidEmail() {
        let repository = MockInvitationRepository()
        let viewModel = InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: repository),
            familyId: "fam-1"
        )
        viewModel.email = "invalid"

        viewModel.send()

        #expect(viewModel.banner?.isError == true)
        #expect(repository.sentEmail == nil)
    }

    @Test("Duplicate pending surfaces error")
    func duplicatePending() async throws {
        let repository = MockInvitationRepository()
        repository.nextResult = .failure(InvitationError.duplicatePending)
        let viewModel = InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: repository),
            familyId: "fam-1"
        )
        viewModel.email = "dup@test.com"

        viewModel.send()
        try await waitUntil { viewModel.banner != nil }

        #expect(viewModel.banner?.isError == true)
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

    throw InviteWaitError.timeout
}

private enum InviteWaitError: Error {
    case timeout
}
