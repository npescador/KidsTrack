import Foundation
@testable import KidsTrack
import Presentation
import Shared
import Domain

final class StubLoginContainer: LoginViewModelBuilding, PasswordResetViewModelBuilding, CreateFamilyViewModelBuilding,
    InviteAdultViewModelBuilding, PendingInvitationsViewModelBuilding, FamilySelectionViewModelBuilding, AuthSessionHandling, SessionResetting,
    FamilyRealtimeSyncProviding {
    var shouldFailLogout: Bool
    var logoutCallCount = 0
    var resetCallCount = 0
    private let dummyRealtimeSyncer = DummyRealtimeSyncer()

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

    func makeInviteAdultViewModel(family: Family) -> InviteAdultViewModel {
        InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: PreviewInvitationRepository()),
            family: family
        )
    }

    func makePendingInvitationsViewModel(userEmail: String, userId: String) -> PendingInvitationsViewModel {
        PendingInvitationsViewModel(
            getInvitations: GetPendingInvitationsUseCase(repository: PreviewInvitationRepository()),
            acceptInvitation: AcceptInvitationUseCase(repository: PreviewInvitationRepository(), familyRepository: PreviewFamilyRepository()),
            rejectInvitation: RejectInvitationUseCase(repository: PreviewInvitationRepository()),
            userEmail: userEmail,
            userId: userId
        )
    }

    var familyRealtimeSyncer: FamilyRealtimeSyncCoordinating {
        dummyRealtimeSyncer
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

private final class DummyRealtimeSyncer: FamilyRealtimeSyncCoordinating {
    var snapshot: FamilyRealtimeSnapshot = .empty

    func switchFamily(to familyId: String) {}
    func restart() {}
    func stop() {}
}
