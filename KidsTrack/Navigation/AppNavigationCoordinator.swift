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
}

/// Coordinates SwiftUI navigation based on high level app flows.
@MainActor
@Observable
final class AppNavigationCoordinator {
    var path = NavigationPath()
    var root: AppRoute = .welcome

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func handle(_ event: AppNavigationEvent) {
        switch event {
        case .didAuthenticate, .showWelcome:
            replaceStack(with: .welcome)
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
            WelcomeView()
        }
    }
}

private extension AppNavigationCoordinator {
    func replaceStack(with route: AppRoute) {
        root = route
        path = NavigationPath()
    }
}
