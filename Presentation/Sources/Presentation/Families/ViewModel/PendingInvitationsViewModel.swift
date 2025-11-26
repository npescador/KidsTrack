import Domain
import Observation
import Shared

@MainActor
@Observable
public final class PendingInvitationsViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case loaded([FamilyInvitation])
        case error(String)
    }

    public struct Banner: Equatable {
        public let message: String
        public let isError: Bool
    }

    public var state: State = .idle
    public var banner: Banner?

    private let getInvitations: GetPendingInvitationsUseCase
    private let acceptInvitation: AcceptInvitationUseCase
    private let rejectInvitation: RejectInvitationUseCase
    private let userEmail: String
    private let userId: String

    public init(
        getInvitations: GetPendingInvitationsUseCase,
        acceptInvitation: AcceptInvitationUseCase,
        rejectInvitation: RejectInvitationUseCase,
        userEmail: String,
        userId: String
    ) {
        self.getInvitations = getInvitations
        self.acceptInvitation = acceptInvitation
        self.rejectInvitation = rejectInvitation
        self.userEmail = userEmail
        self.userId = userId
    }

    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    public func load() {
        state = .loading
        banner = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let invitations = try await getInvitations.execute(email: userEmail)
                await MainActor.run {
                    state = .loaded(invitations)
                }
            } catch {
                await MainActor.run {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }

    public func accept(_ invitation: FamilyInvitation, onAccepted: @escaping (Family) -> Void) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let family = try await acceptInvitation.execute(invitationId: invitation.id, userId: userId)
                await MainActor.run {
                    remove(invitation)
                    banner = Banner(
                        message: String(localized: "invitations.accept.success".localized()),
                        isError: false
                    )
                    onAccepted(family)
                }
            } catch {
                await MainActor.run {
                    banner = Banner(message: message(for: error), isError: true)
                }
            }
        }
    }

    public func reject(_ invitation: FamilyInvitation) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await rejectInvitation.execute(invitationId: invitation.id)
                await MainActor.run {
                    remove(invitation)
                    banner = Banner(
                        message: String(localized: "invitations.reject.success".localized()),
                        isError: false
                    )
                }
            } catch {
                await MainActor.run {
                    banner = Banner(message: message(for: error), isError: true)
                }
            }
        }
    }

    private func remove(_ invitation: FamilyInvitation) {
        guard case .loaded(var invitations) = state else { return }
        invitations.removeAll { $0.id == invitation.id }
        state = .loaded(invitations)
    }

    private func message(for error: Error) -> String {
        if let invitationError = error as? InvitationError, let key = invitationError.localizationKey {
            return String(localized: key.localized())
        }
        return error.localizedDescription
    }
}
