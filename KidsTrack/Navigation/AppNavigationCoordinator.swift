import Observation
import Presentation
import Shared
import SwiftUI

/// Routes supported by the application level navigation stack.
enum AppRoute: Hashable {
    case login
    case welcome
    case authenticatedShell
    case passwordReset
    case familySelection
}

/// High level events that mutate the active flow (auth completed, logout, etc).
enum AppNavigationEvent {
    case didAuthenticate
    case didLogout
    case showWelcome
    case showLogin
    case showPasswordReset
}

/// Coordinates SwiftUI navigation based on high level app flows.
@MainActor
@Observable
final class AppNavigationCoordinator {
    var path = NavigationPath()
    var root: AppRoute = .welcome
    var logoutError: String?
    var shouldConfirmLogout = false
    var activeFamily: Family?

    private let loginFactory: LoginViewModelBuilding
    private let passwordResetFactory: PasswordResetViewModelBuilding
    private let homeFactory: HomeViewModelBuilding
    private let familySelectionFactory: FamilySelectionViewModelBuilding
    private let createFamilyFactory: CreateFamilyViewModelBuilding
    private let inviteAdultFactory: InviteAdultViewModelBuilding
    private let pendingInvitesFactory: PendingInvitationsViewModelBuilding
    private let createChildFactory: CreateChildViewModelBuilding
    private let sessionHandler: AuthSessionHandling
    private let sessionResetter: SessionResetting

    init(
        loginFactory: LoginViewModelBuilding,
        passwordResetFactory: PasswordResetViewModelBuilding,
        homeFactory: HomeViewModelBuilding,
        familySelectionFactory: FamilySelectionViewModelBuilding,
        createFamilyFactory: CreateFamilyViewModelBuilding,
        inviteAdultFactory: InviteAdultViewModelBuilding,
        pendingInvitesFactory: PendingInvitationsViewModelBuilding,
        createChildFactory: CreateChildViewModelBuilding,
        sessionHandler: AuthSessionHandling,
        sessionResetter: SessionResetting
    ) {
        self.loginFactory = loginFactory
        self.passwordResetFactory = passwordResetFactory
        self.homeFactory = homeFactory
        self.familySelectionFactory = familySelectionFactory
        self.createFamilyFactory = createFamilyFactory
        self.inviteAdultFactory = inviteAdultFactory
        self.pendingInvitesFactory = pendingInvitesFactory
        self.createChildFactory = createChildFactory
        self.sessionHandler = sessionHandler
        self.sessionResetter = sessionResetter
    }

    func handle(_ event: AppNavigationEvent) {
        switch event {
        case .didAuthenticate:
            replaceStack(with: .authenticatedShell)
        case .showWelcome:
            replaceStack(with: .welcome)
        case .showLogin:
            replaceStack(with: .login)
        case .didLogout:
            activeFamily = nil
            replaceStack(with: .login)
        case .showPasswordReset:
            navigate(to: .passwordReset)
        }
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    @ViewBuilder
    func makeDestination(for route: AppRoute) -> some View {
        switch route {
        case .login:
            LoginView(
                viewModel: loginFactory.makeLoginViewModel(),
                onAuthenticated: { [weak self] in
                    self?.handle(.didAuthenticate)
                },
                onForgotPassword: { [weak self] in
                    self?.handle(.showPasswordReset)
                }
            )
        case .welcome:
            WelcomeView(onGetStarted: { [weak self] in
                self?.handle(.showLogin)
            })
        case .passwordReset:
            PasswordResetView(
                viewModel: passwordResetFactory.makePasswordResetViewModel()
            )
        case .authenticatedShell:
            HomeView(
                viewModel: homeFactory.makeHomeViewModel(),
                onManageFamilies: { [weak self] in
                    self?.navigate(to: .familySelection)
                },
                onOpenSchedule: nil,
                onOpenActivities: nil,
                onOpenExpenses: nil,
                onLogout: { [weak self] in
                    self?.attemptLogout()
                },
                makeCreateChildViewModel: { [weak self] family in
                    guard let self else { return nil }
                    return self.createChildFactory.makeCreateChildViewModel(family: family)
                },
                makeEditChildViewModel: { [weak self] family, child in
                    guard let self else { return nil }
                    return self.createChildFactory.makeEditChildViewModel(family: family, child: child)
                },
                makeDeleteChildViewModel: { [weak self] family, child in
                    guard let self else { return nil }
                    return self.createChildFactory.makeDeleteChildViewModel(family: family, child: child)
                }
            )
        case .familySelection:
            FamilySelectionView(
                viewModel: familySelectionFactory.makeFamilySelectionViewModel(),
                makeCreateFamilyViewModel: { [weak self] in
                    guard let self else {
                        return CreateFamilyViewModel.preview()
                    }
                    return self.createFamilyFactory.makeCreateFamilyViewModel()
                },
                makeInviteAdultViewModel: { [weak self] family in
                    guard let self else {
                        return nil
                    }
                    return self.inviteAdultFactory.makeInviteAdultViewModel(family: family)
                },
                makePendingInvitationsViewModel: { [weak self] email, userId in
                    guard let self else { return nil }
                    return self.pendingInvitesFactory.makePendingInvitationsViewModel(userEmail: email, userId: userId)
                },
                makeCreateChildViewModel: { [weak self] family in
                    guard let self else { return nil }
                    return self.createChildFactory.makeCreateChildViewModel(family: family)
                },
                makeEditChildViewModel: { [weak self] family, child in
                    guard let self else { return nil }
                    return self.createChildFactory.makeEditChildViewModel(family: family, child: child)
                },
                makeDeleteChildViewModel: { [weak self] family, child in
                    guard let self else { return nil }
                    return self.createChildFactory.makeDeleteChildViewModel(family: family, child: child)
                },
                onLogout: { [weak self] in
                    self?.attemptLogout()
                },
                onCreateFamily: { [weak self] family in
                    self?.handleFamilyCreated(family)
                }
            )
        }
    }
}

extension AppNavigationCoordinator {
    func replaceStack(with route: AppRoute) {
        root = route
        path = NavigationPath()
    }

    func attemptLogout() {
        logoutError = nil
        shouldConfirmLogout = false
        Task { [weak self] in
            guard let self else { return }
            await sessionResetter.resetSession()
            do {
                try await sessionHandler.logout()
                await MainActor.run {
                    self.handle(.didLogout)
                }
            } catch {
                await MainActor.run {
                    let authError = error as? AuthError
                    self.logoutError = authError?.userMessage ?? error.localizedDescription
                }
            }
        }
    }

    func handleFamilyCreated(_ family: Family) {
        activeFamily = family
        // In future this should trigger navigation to the family dashboard.
    }
}

extension AppNavigationCoordinator {
    convenience init(
        container: LoginViewModelBuilding & PasswordResetViewModelBuilding &
        CreateFamilyViewModelBuilding & InviteAdultViewModelBuilding & PendingInvitationsViewModelBuilding &
        CreateChildViewModelBuilding & HomeViewModelBuilding &
        FamilySelectionViewModelBuilding & AuthSessionHandling & SessionResetting
    ) {
        self.init(
            loginFactory: container,
            passwordResetFactory: container,
            homeFactory: container,
            familySelectionFactory: container,
            createFamilyFactory: container,
            inviteAdultFactory: container,
            pendingInvitesFactory: container,
            createChildFactory: container,
            sessionHandler: container,
            sessionResetter: container
        )
    }
}
