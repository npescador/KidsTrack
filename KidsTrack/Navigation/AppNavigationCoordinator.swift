import Observation
import Presentation
import SwiftUI

/// Routes supported by the application level navigation stack.
enum AppRoute: Hashable {
    case login
    case welcome
}

/// High level events that mutate the active flow (auth completed, logout, etc).
enum AppNavigationEvent {
    case didAuthenticate
    case didLogout
    case showWelcome
    case showLogin
}

/// Coordinates SwiftUI navigation based on high level app flows.
@MainActor
@Observable
final class AppNavigationCoordinator {
    var path = NavigationPath()
    var root: AppRoute = .welcome
    // TODO: Persist onboarding completion so we can skip the welcome route when appropriate.

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func handle(_ event: AppNavigationEvent) {
        switch event {
        case .didAuthenticate, .showWelcome:
            replaceStack(with: .welcome)
        case .showLogin:
            navigate(to: .login)
        case .didLogout:
            replaceStack(with: .login)
        }
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    @ViewBuilder
    func makeDestination(for route: AppRoute) -> some View {
        switch route {
        case .login:
            LoginView(viewModel: container.makeLoginViewModel())
        case .welcome:
            WelcomeView(onGetStarted: { [weak self] in
                self?.handle(.showLogin)
            })
        }
    }
}

private extension AppNavigationCoordinator {
    func replaceStack(with route: AppRoute) {
        root = route
        path = NavigationPath()
    }
}
