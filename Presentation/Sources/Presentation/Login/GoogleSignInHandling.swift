import Foundation
import UIKit

public struct GoogleSignInTokens: Sendable {
    public let idToken: String
    public let accessToken: String

    public init(idToken: String, accessToken: String) {
        self.idToken = idToken
        self.accessToken = accessToken
    }
}

/// Abstraction over Google Sign-In so Presentation is not tied to the SDK.
public protocol GoogleSignInHandling: AnyObject {
    @MainActor
    func signIn(presentingViewController: UIViewController) async throws -> GoogleSignInTokens
}
