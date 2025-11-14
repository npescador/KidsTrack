import Foundation

/// Lightweight representation of an authenticated user.
public struct AuthUser: Equatable, Sendable {
    public let id: String
    public let email: String

    public init(id: String, email: String) {
        self.id = id
        self.email = email
    }
}

/// Authentication state updates so upper layers can react to sign-in/sign-out transitions.
public enum AuthState: Equatable, Sendable {
    case authenticated(AuthUser)
    case unauthenticated
}
