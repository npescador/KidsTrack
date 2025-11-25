import Foundation
@testable import KidsTrack
import Presentation
import Shared

final class StubLoginContainer: LoginViewModelBuilding, PasswordResetViewModelBuilding, AuthSessionHandling,
    SessionResetting
{
    var shouldFailLogout: Bool
    var logoutCallCount = 0
    var resetCallCount = 0

    init(shouldFailLogout: Bool = false) {
        self.shouldFailLogout = shouldFailLogout
    }

    func makeLoginViewModel() -> LoginViewModel {
        .preview()
    }

    func makePasswordResetViewModel() -> PasswordResetViewModel {
        .preview()
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
