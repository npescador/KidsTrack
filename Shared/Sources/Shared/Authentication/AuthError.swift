import Foundation

/// Domain-facing authentication errors shared across layers.
public enum AuthError: Error, Equatable, Sendable {
    case network
    case invalidCredentials
    case userNotFound
    case userAlreadyExists
    case sessionExpired
    case missingImplementation
    case unknown(message: String)

    /// User-friendly message that Presentation can surface without duplicating logic.
    public var userMessage: String {
        switch self {
        case .network:
            return "We could not reach the server. Check your connection and try again."
        case .invalidCredentials:
            return "The email or password entered is invalid."
        case .userNotFound:
            return "No account was found for that email."
        case .userAlreadyExists:
            return "An account with this email already exists."
        case .sessionExpired:
            return "Your session expired. Please sign in again."
        case .missingImplementation:
            return "Authentication is not configured for this build."
        case let .unknown(message):
            return message.isEmpty ? "Something went wrong. Please try again." : message
        }
    }
}
