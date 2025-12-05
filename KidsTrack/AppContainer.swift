import Data
import Domain
import Foundation
import Presentation
import Shared

/// Factory surface to create login view models without binding callers to the concrete container.
protocol LoginViewModelBuilding {
    func makeLoginViewModel() -> LoginViewModel
}

protocol PasswordResetViewModelBuilding {
    func makePasswordResetViewModel() -> PasswordResetViewModel
}

protocol CreateFamilyViewModelBuilding {
    func makeCreateFamilyViewModel() -> CreateFamilyViewModel
}

protocol HomeViewModelBuilding {
    func makeHomeViewModel() -> HomeViewModel
}

protocol InviteAdultViewModelBuilding {
    func makeInviteAdultViewModel(family: Family) -> InviteAdultViewModel
}

protocol PendingInvitationsViewModelBuilding {
    func makePendingInvitationsViewModel(userEmail: String, userId: String) -> PendingInvitationsViewModel
}

protocol FamilySelectionViewModelBuilding {
    func makeFamilySelectionViewModel() -> FamilySelectionViewModel
}

protocol CreateChildViewModelBuilding {
    func makeCreateChildViewModel(family: Family) -> CreateChildViewModel?
    func makeEditChildViewModel(family: Family, child: Child) -> CreateChildViewModel?
    func makeDeleteChildViewModel(family: Family, child: Child) -> DeleteChildViewModel?
}

protocol FamilyRealtimeSyncProviding {
    var familyRealtimeSyncer: FamilyRealtimeSyncCoordinating { get }
}

/// Contract for clearing app/session state (listeners, caches) on logout.
protocol SessionResetting {
    func resetSession() async
}

/// Minimal auth session actions needed outside the login screen.
protocol AuthSessionHandling {
    func logout() async throws
}

/// Simple composition root wiring Firebase-backed dependencies.
@MainActor
final class AppContainer: LoginViewModelBuilding, PasswordResetViewModelBuilding,
    CreateFamilyViewModelBuilding, HomeViewModelBuilding, InviteAdultViewModelBuilding,
    PendingInvitationsViewModelBuilding,
    FamilySelectionViewModelBuilding, CreateChildViewModelBuilding,
    AuthSessionHandling, SessionResetting, FamilyRealtimeSyncProviding {
    private let authRepository: AuthRepositoryProtocol
    private let googleSignInHandler: GoogleSignInHandling
    private let familyRepository: FamilyRepositoryProtocol
    private let activeFamilyStore: ActiveFamilyStoreProtocol
    private let sessionProvider: UserSessionProviding
    private let invitationRepository: InvitationRepositoryProtocol
    private let realtimeRepository: FamilyRealtimeRepositoryProtocol
    private let realtimeSyncer: FamilyRealtimeSyncCoordinator
    private let childrenRepository: ChildrenRepositoryProtocol

    init() {
        let dataSource = FirebaseAuthDataSource()
        self.authRepository = AuthRepository(dataSource: dataSource)
        self.googleSignInHandler = GoogleSignInAdapter()
        #if DEBUG
        let useInMemoryFamilies = ProcessInfo.processInfo.environment["KIDSTRACK_FAMILIES_INMEMORY"] == "1"
        let familiesRemote: FamiliesRemoteDataSourceProtocol = useInMemoryFamilies
            ? InMemoryFamiliesRemoteDataSource()
            : FirestoreFamiliesRemoteDataSource()
        #else
        let familiesRemote: FamiliesRemoteDataSourceProtocol = FirestoreFamiliesRemoteDataSource()
        #endif

        self.familyRepository = FamiliesRepository(
            remoteDataSource: familiesRemote
        )
        self.activeFamilyStore = UserDefaultsActiveFamilyStore()
        self.sessionProvider = FirebaseUserSessionProvider()
        self.invitationRepository = InvitationsRepository(
            remote: InMemoryInvitationsRemoteDataSource()
        )
        #if DEBUG
        let useInMemoryRealtime = ProcessInfo.processInfo.environment["KIDSTRACK_REALTIME_INMEMORY"] == "1"
        let realtimeRemote: FamilyRealtimeRemoteDataSourceProtocol = useInMemoryRealtime
            ? InMemoryFamilyRealtimeRemoteDataSource()
            : FirestoreFamilyRealtimeRemoteDataSource()
        let childrenRemote: ChildrenRemoteDataSourceProtocol
        if let inMemory = realtimeRemote as? ChildrenRemoteDataSourceProtocol {
            childrenRemote = inMemory
        } else {
            childrenRemote = FirestoreChildrenRemoteDataSource()
        }
        #else
        let realtimeRemote = FirestoreFamilyRealtimeRemoteDataSource()
        let childrenRemote: ChildrenRemoteDataSourceProtocol = FirestoreChildrenRemoteDataSource()
        #endif
        self.realtimeRepository = FamilyRealtimeRepository(remote: realtimeRemote)
        self.childrenRepository = ChildrenRepository(remote: childrenRemote)
        self.realtimeSyncer = FamilyRealtimeSyncCoordinator(
            observeRealtime: ObserveFamilyRealtimeUseCase(repository: realtimeRepository)
        )
    }

    var familyRealtimeSyncer: FamilyRealtimeSyncCoordinating {
        realtimeSyncer
    }

    func makeLoginViewModel() -> LoginViewModel {
        let login = LoginUseCase(repository: authRepository)
        let register = RegisterUseCase(repository: authRepository)
        let google = SignInWithGoogleUseCase(repository: authRepository)
        let reset = SendPasswordResetUseCase(repository: authRepository)
        let logout = LogoutUseCase(repository: authRepository)
        let observe = ObserveAuthStateUseCase(repository: authRepository)

        return LoginViewModel(
            loginUseCase: login,
            registerUseCase: register,
            googleSignInUseCase: google,
            googleSignInHandler: googleSignInHandler,
            passwordResetUseCase: reset,
            logoutUseCase: logout,
            observeAuthStateUseCase: observe
        )
    }

    func makePasswordResetViewModel() -> PasswordResetViewModel {
        PasswordResetViewModel(
            resetUseCase: SendPasswordResetUseCase(repository: authRepository)
        )
    }

    func makeCreateFamilyViewModel() -> CreateFamilyViewModel {
        CreateFamilyViewModel(
            createFamilyUseCase: CreateFamilyUseCase(
                repository: familyRepository,
                activeStore: activeFamilyStore
            ),
            sessionProvider: sessionProvider
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: familyRepository),
            setActiveFamily: SetActiveFamilyUseCase(store: activeFamilyStore),
            activeFamilyStore: activeFamilyStore,
            sessionProvider: sessionProvider,
            realtimeSyncer: realtimeSyncer
        )
    }

    func makeFamilySelectionViewModel() -> FamilySelectionViewModel {
        FamilySelectionViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: familyRepository),
            setActiveFamily: SetActiveFamilyUseCase(store: activeFamilyStore),
            activeFamilyStore: activeFamilyStore,
            sessionProvider: sessionProvider,
            realtimeSyncer: realtimeSyncer
        )
    }

    func makeCreateChildViewModel(family: Family) -> CreateChildViewModel? {
        CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: childrenRepository),
            updateChild: UpdateChildUseCase(repository: childrenRepository),
            existingChild: nil
        )
    }

    func makeEditChildViewModel(family: Family, child: Child) -> CreateChildViewModel? {
        CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: childrenRepository),
            updateChild: UpdateChildUseCase(repository: childrenRepository),
            existingChild: child
        )
    }

    func makeDeleteChildViewModel(family: Family, child: Child) -> DeleteChildViewModel? {
        DeleteChildViewModel(
            family: family,
            child: child,
            deleteChild: DeleteChildUseCase(repository: childrenRepository)
        )
    }

    func makeInviteAdultViewModel(family: Family) -> InviteAdultViewModel {
        InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: invitationRepository),
            family: family
        )
    }

    func makePendingInvitationsViewModel(userEmail: String, userId: String) -> PendingInvitationsViewModel {
        PendingInvitationsViewModel(
            getInvitations: GetPendingInvitationsUseCase(repository: invitationRepository),
            acceptInvitation: AcceptInvitationUseCase(
                repository: invitationRepository,
                familyRepository: familyRepository
            ),
            rejectInvitation: RejectInvitationUseCase(repository: invitationRepository),
            userEmail: userEmail,
            userId: userId
        )
    }

    func resetSession() async {
        await activeFamilyStore.clearActiveFamily()
        realtimeSyncer.stop()
    }

    func logout() async throws {
        let logout = LogoutUseCase(repository: authRepository)
        try await logout.execute()
    }
}
