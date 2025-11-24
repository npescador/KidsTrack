import SwiftUI
@testable import KidsTrack
import Presentation
import Testing

@MainActor
@Suite("AppNavigationCoordinator")
struct AppNavigationCoordinatorTests {
    @Test("didAuthenticate replaces stack with authenticated shell")
    func didAuthenticateRoutesToShell() {
        let coordinator = AppNavigationCoordinator(container: StubLoginContainer())

        coordinator.handle(.didAuthenticate)

        #expect(coordinator.root == .authenticatedShell)
        #expect(coordinator.path.count == 0)
    }

    @Test("showLogin pushes login route")
    func showLoginPushesLogin() {
        let coordinator = AppNavigationCoordinator(container: StubLoginContainer())

        coordinator.handle(.showLogin)

        #expect(coordinator.path.count == 1)
    }

    @Test("didLogout resets to login root")
    func didLogoutResetsToLogin() {
        let coordinator = AppNavigationCoordinator(container: StubLoginContainer())
        coordinator.handle(.didAuthenticate)
        #expect(coordinator.root == .authenticatedShell)

        coordinator.handle(.didLogout)

        #expect(coordinator.root == .login)
        #expect(coordinator.path.count == 0)
    }
}

private struct StubLoginContainer: LoginViewModelBuilding, AuthSessionHandling {
    func makeLoginViewModel() -> LoginViewModel {
        .preview()
    }

    func logout() async throws {}
}
