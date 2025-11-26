import Data
import Domain
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

protocol InviteAdultViewModelBuilding {
    func makeInviteAdultViewModel(familyId: String) -> InviteAdultViewModel
}

protocol FamilySelectionViewModelBuilding {
    func makeFamilySelectionViewModel() -> FamilySelectionViewModel
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
    CreateFamilyViewModelBuilding, InviteAdultViewModelBuilding,
                            FamilySelectionViewModelBuilding, AuthSessionHandling, SessionResetting {
    private let authRepository: AuthRepositoryProtocol
    private let googleSignInHandler: GoogleSignInHandling
    private let familyRepository: FamilyRepositoryProtocol
    private let activeFamilyStore: ActiveFamilyStoreProtocol
    private let sessionProvider: UserSessionProviding
    private let invitationRepository: InvitationRepositoryProtocol

    init() {
        let dataSource = FirebaseAuthDataSource()
        self.authRepository = AuthRepository(dataSource: dataSource)
        self.googleSignInHandler = GoogleSignInAdapter()
        self.familyRepository = FamiliesRepository(
            remoteDataSource: InMemoryFamiliesRemoteDataSource()
        )
        self.activeFamilyStore = UserDefaultsActiveFamilyStore()
        self.sessionProvider = FirebaseUserSessionProvider()
        self.invitationRepository = InvitationsRepository(
            remote: InMemoryInvitationsRemoteDataSource()
        )
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

    func makeFamilySelectionViewModel() -> FamilySelectionViewModel {
        FamilySelectionViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: familyRepository),
            setActiveFamily: SetActiveFamilyUseCase(store: activeFamilyStore),
            activeFamilyStore: activeFamilyStore,
            sessionProvider: sessionProvider
        )
    }

    func makeInviteAdultViewModel(familyId: String) -> InviteAdultViewModel {
        InviteAdultViewModel(
            sendInvitation: SendFamilyInvitationUseCase(repository: invitationRepository),
            familyId: familyId
        )
    }

    func resetSession() async {
        await activeFamilyStore.clearActiveFamily()
    }

    func logout() async throws {
        let logout = LogoutUseCase(repository: authRepository)
        try await logout.execute()
    }
}
