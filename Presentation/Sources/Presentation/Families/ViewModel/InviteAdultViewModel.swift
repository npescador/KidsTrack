import Domain
import Observation
import Shared

@MainActor
@Observable
public final class InviteAdultViewModel {
    public struct Banner: Equatable {
        public let message: String
        public let isError: Bool
    }

    public var email = ""
    public var isLoading = false
    public var banner: Banner?
    public var didSendSuccessfully = false

    private let sendInvitation: SendFamilyInvitationUseCase
    private let family: Family

    public init(
        sendInvitation: SendFamilyInvitationUseCase,
        family: Family
    ) {
        self.sendInvitation = sendInvitation
        self.family = family
    }

    public var isSubmitDisabled: Bool {
        isLoading || !isValidEmail(email)
    }

    public func send() {
        guard !isSubmitDisabled else {
            banner = Banner(
                message: "invite.error.invalid.email".localizedText(),
                isError: true
            )
            return
        }

        isLoading = true
        banner = nil
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let useCase = sendInvitation

        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await useCase.execute(family: family, email: email)
                await MainActor.run {
                    self.isLoading = false
                    self.banner = Banner(
                        message: "invite.success.banner".localizedText(),
                        isError: false
                    )
                    self.email = ""
                    self.didSendSuccessfully = true
                }
            } catch {
                let message: String
                if let invitationError = error as? InvitationError {
                    if let key = invitationError.localizationKey {
                        message = key.localizedText()
                    } else {
                        message = invitationError.userMessage
                    }
                } else {
                    message = error.localizedDescription
                }
                await MainActor.run {
                    self.isLoading = false
                    self.banner = Banner(message: message, isError: true)
                    self.didSendSuccessfully = false
                }
            }
        }
    }
}

private extension InviteAdultViewModel {
    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
