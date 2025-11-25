import Presentation
import UIKit

final class GoogleSignInHandlerStub: GoogleSignInHandling {
    var result: Result<GoogleSignInTokens, Error>

    init(
        result: Result<GoogleSignInTokens, Error> = .success(
            GoogleSignInTokens(
                idToken: "id",
                accessToken: "token"
            )
        )
    ) {
        self.result = result
    }

    @MainActor
    func signIn(presentingViewController: UIViewController) async throws -> GoogleSignInTokens {
        try result.get()
    }
}
