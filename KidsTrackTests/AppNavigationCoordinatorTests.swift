import Foundation
import SwiftUI
@testable import KidsTrack
import Presentation
import Shared
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

    @Test("attemptLogout navigates to login on success")
    func attemptLogoutSuccess() async throws {
        let container = StubLoginContainer()
        let coordinator = AppNavigationCoordinator(container: container)
        coordinator.handle(.didAuthenticate)
        coordinator.shouldConfirmLogout = true

        coordinator.attemptLogout()

        try await waitUntil { coordinator.root == .login }
        #expect(container.logoutCallCount == 1)
    }

    @Test("attemptLogout surfaces error and stays on shell when failing")
    func attemptLogoutFailure() async throws {
        let container = StubLoginContainer(shouldFailLogout: true)
        let coordinator = AppNavigationCoordinator(container: container)
        coordinator.handle(.didAuthenticate)
        coordinator.shouldConfirmLogout = true

        coordinator.attemptLogout()

        try await waitUntil { container.logoutCallCount == 1 }
        #expect(coordinator.root == .authenticatedShell)
        #expect(coordinator.logoutError?.isEmpty == false)
    }
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping @MainActor () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while clock.now < deadline {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: 20_000_000)
    }

    throw WaitError.timeout
}

enum WaitError: Error {
    case timeout
}
