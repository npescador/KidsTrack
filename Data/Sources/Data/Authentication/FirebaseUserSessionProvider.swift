import FirebaseAuth
import Shared

public struct FirebaseUserSessionProvider: UserSessionProviding {
    public init() {}

    public var currentUser: AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthUser(id: user.uid, email: user.email ?? "")
    }
}
