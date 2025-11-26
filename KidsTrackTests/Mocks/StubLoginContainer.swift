import Foundation
@testable import KidsTrack
import Presentation
import Shared
import Domain

final class StubLoginContainer: LoginViewModelBuilding, PasswordResetViewModelBuilding, CreateFamilyViewModelBuilding,
    InviteAdultViewModelBuilding, FamilySelectionViewModelBuilding, AuthSessionHandling, SessionResetting
{
    var shouldFailLogout: Bool
    var logoutCallCount = 0
    var resetCallCount = 0

    init(shouldFailLogout: Bool = false) {
        self.shouldFailLogout = shouldFailLogout
    }

    func makeLoginViewModel() -> LoginViewModel {
        .preview()
    }

    func makePasswordResetViewModel() -> PasswordResetViewModel {
        .preview()
    }

    func makeCreateFamilyViewModel() -> CreateFamilyViewModel {
        .preview()
    }

    func makeFamilySelectionViewModel() -> FamilySelectionViewModel {
        FamilySelectionViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: PreviewFamilyRepository()),
            setActiveFamily: SetActiveFamilyUseCase(store: PreviewActiveFamilyStore()),
            activeFamilyStore: PreviewActiveFamilyStore(),
            sessionProvider: PreviewUserSessionProvider()
        )
    }

    func makeInviteAdultViewModel(familyId: String) -> InviteAdultViewModel {
        InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: PreviewInvitationRepository()),
            familyId: familyId
        )
    }

    func resetSession() async {
        resetCallCount += 1
    }

    func logout() async throws {
        logoutCallCount += 1
        if shouldFailLogout {
            throw AuthError.network
        }
    }
}
