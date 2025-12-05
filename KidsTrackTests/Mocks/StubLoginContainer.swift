import Foundation
import Observation
@testable import KidsTrack
import Presentation
import Shared
import Domain

@MainActor
final class StubLoginContainer: LoginViewModelBuilding, PasswordResetViewModelBuilding,
    CreateFamilyViewModelBuilding, HomeViewModelBuilding, InviteAdultViewModelBuilding, PendingInvitationsViewModelBuilding,
    FamilySelectionViewModelBuilding, CreateChildViewModelBuilding,
    AuthSessionHandling, SessionResetting, FamilyRealtimeSyncProviding {
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

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: PreviewFamilyRepository()),
            setActiveFamily: SetActiveFamilyUseCase(store: PreviewActiveFamilyStore()),
            activeFamilyStore: PreviewActiveFamilyStore(),
            sessionProvider: PreviewUserSessionProvider(),
            realtimeSyncer: dummyRealtimeSyncer
        )
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

    func makeCreateChildViewModel(family: Family) -> CreateChildViewModel? {
        CreateChildViewModel.preview(family: family)
    }

    func makeEditChildViewModel(family: Family, child: Child) -> CreateChildViewModel? {
        CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: PreviewChildrenRepository()),
            updateChild: UpdateChildUseCase(repository: PreviewChildrenRepository()),
            existingChild: child
        )
    }

    func makeDeleteChildViewModel(family: Family, child: Child) -> DeleteChildViewModel? {
        DeleteChildViewModel(
            family: family,
            child: child,
            deleteChild: DeleteChildUseCase(repository: PreviewChildrenRepository())
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

@MainActor
@Observable
private final class DummyRealtimeSyncer: FamilyRealtimeSyncCoordinating {
    var snapshot: FamilyRealtimeSnapshot = .empty
    private var continuation: AsyncStream<FamilyRealtimeSnapshot>.Continuation?

    func switchFamily(to familyId: String) {}
    func restart() {}
    func stop() {}

    func observeSnapshot() -> AsyncStream<FamilyRealtimeSnapshot> {
        AsyncStream { continuation in
            Task { @MainActor [weak self] in
                self?.continuation = continuation
                continuation.yield(self?.snapshot ?? .empty)
            }

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.continuation = nil
                }
            }
        }
    }
}
