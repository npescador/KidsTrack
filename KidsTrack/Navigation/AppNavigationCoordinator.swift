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
    // TODO: Persist onboarding completion so we can skip the welcome route when appropriate.

    private let loginFactory: LoginViewModelBuilding
    private let passwordResetFactory: PasswordResetViewModelBuilding
    private let sessionHandler: AuthSessionHandling

    init(
        loginFactory: LoginViewModelBuilding,
        passwordResetFactory: PasswordResetViewModelBuilding,
        sessionHandler: AuthSessionHandling
    ) {
        self.loginFactory = loginFactory
        self.passwordResetFactory = passwordResetFactory
        self.sessionHandler = sessionHandler
    }

    func handle(_ event: AppNavigationEvent) {
        switch event {
        case .didAuthenticate:
            replaceStack(with: .authenticatedShell)
        case .showWelcome:
            replaceStack(with: .welcome)
        case .showLogin:
            navigate(to: .login)
        case .didLogout:
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
            FamilySelectionPlaceholderView(
                isShowingLogoutAlert: shouldConfirmLogout,
                onConfirmLogout: { [weak self] in
                    self?.attemptLogout()
                },
                onCancelLogout: { [weak self] in
                    self?.shouldConfirmLogout = false
                },
                errorMessage: logoutError,
                onDismissError: { [weak self] in
                    self?.logoutError = nil
                },
                onCreateFamily: {},
                onLogout: { [weak self] in
                    self?.shouldConfirmLogout = true
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
}
