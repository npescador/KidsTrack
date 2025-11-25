import GoogleSignIn
import Presentation
import Shared
import UIKit

final class GoogleSignInAdapter: GoogleSignInHandling {
    @MainActor
    func signIn(presentingViewController: UIViewController) async throws -> GoogleSignInTokens {
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown(message: "Missing Google ID token.")
            }
            let accessToken = result.user.accessToken.tokenString
            return GoogleSignInTokens(idToken: idToken, accessToken: accessToken)
        } catch {
            let nsError = error as NSError
            if nsError.code == GIDSignInError.canceled.rawValue {
                throw AuthError.userCancelled
            }
            throw AuthError.unknown(message: error.localizedDescription)
        }
    }
}
