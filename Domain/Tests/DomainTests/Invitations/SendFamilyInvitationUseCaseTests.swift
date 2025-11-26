import Domain
import Shared
import Testing

@Suite("SendFamilyInvitationUseCase")
struct SendFamilyInvitationUseCaseTests {
    @Test("Sends invitation successfully")
    func sendInvitationSuccess() async throws {
        let repository = MockInvitationRepository()
        let expected = FamilyInvitation(id: "inv-1", familyId: "fam-1", email: "test@kidstrack.app")
        repository.nextResult = .success(expected)
        let useCase = SendFamilyInvitationUseCase(repository: repository)

        let invitation = try await useCase.execute(familyId: "fam-1", email: "test@kidstrack.app")

        #expect(invitation == expected)
        #expect(repository.sentFamilyId == "fam-1")
        #expect(repository.sentEmail == "test@kidstrack.app")
    }

    @Test("Bubbles duplicate pending error")
    func duplicatePending() async {
        let repository = MockInvitationRepository()
        repository.nextResult = .failure(InvitationError.duplicatePending)
        let useCase = SendFamilyInvitationUseCase(repository: repository)

        do {
            _ = try await useCase.execute(familyId: "fam-1", email: "dup@kidstrack.app")
            Issue.record("Expected duplicate error")
        } catch {
            #expect(error as? InvitationError == .duplicatePending)
        }
    }
}
