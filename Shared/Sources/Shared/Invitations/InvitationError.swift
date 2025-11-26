import Foundation

public enum InvitationError: Error, Equatable, Sendable {
    case duplicatePending
    case network
    case unknown(message: String)

    public var localizationKey: String? {
        switch self {
        case .duplicatePending:
            return "invite.error.duplicate.pending"
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
        case .network:
            return "We couldn't send the invitation. Check your connection and try again."
        case let .unknown(message):
            return message.isEmpty ? "Something went wrong. Please try again." : message
        }
    }
}
