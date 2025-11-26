import Foundation

public enum InvitationError: Error, Equatable, Sendable {
    case duplicatePending
    case notFound
    case alreadyHandled
    case network
    case unknown(message: String)

    public var localizationKey: String? {
        switch self {
        case .duplicatePending:
            return "invite.error.duplicate.pending"
        case .notFound:
            return "invite.error.notfound"
        case .alreadyHandled:
            return "invite.error.already.handled"
        case .network:
            return "invite.error.network"
        case let .unknown(message):
            return message.isEmpty ? "invite.error.unknown" : nil
        }
    }

    public var userMessage: String {
        switch self {
        case .duplicatePending:
            return "An invitation is already pending for this email."
        case .notFound:
            return "Invitation not found or expired."
        case .alreadyHandled:
            return "This invitation was already handled."
        case .network:
            return "We couldn't send the invitation. Check your connection and try again."
        case let .unknown(message):
            return message.isEmpty ? "Something went wrong. Please try again." : message
        }
    }
}
