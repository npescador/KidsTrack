import Foundation
@testable import KidsTrack
import Presentation
import Shared

final class StubLoginContainer: LoginViewModelBuilding, AuthSessionHandling {
    var shouldFailLogout: Bool
    var logoutCallCount = 0

    init(shouldFailLogout: Bool = false) {
        self.shouldFailLogout = shouldFailLogout
    }

    func makeLoginViewModel() -> LoginViewModel {
        .preview()
    }

    func logout() async throws {
        logoutCallCount += 1
        if shouldFailLogout {
            throw AuthError.network
        }
    }
}
