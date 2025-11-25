import Foundation
import UIKit

#if DEBUG
final class PreviewGoogleSignInHandler: GoogleSignInHandling {
    @MainActor
    func signIn(presentingViewController: UIViewController) async throws -> GoogleSignInTokens {
        GoogleSignInTokens(idToken: "id", accessToken: "token")
    }
}
#endif
