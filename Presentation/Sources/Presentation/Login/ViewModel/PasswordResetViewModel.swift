import Domain
import Foundation
import Observation
import Shared

@MainActor
@Observable
public final class PasswordResetViewModel {
    public struct Banner: Equatable {
        public enum Style {
            case success
            case error
            case info
        }

        public let style: Style
        public let message: String

        public init(style: Style, message: String) {
            self.style = style
            self.message = message
        }
    }

    public var email = ""
    public var isLoading = false
    public var banner: Banner?

    private let resetUseCase: SendPasswordResetUseCase

    public init(resetUseCase: SendPasswordResetUseCase) {
        self.resetUseCase = resetUseCase
    }

    public var isFormValid: Bool {
        isValidEmail(email)
    }

    public var isPrimaryDisabled: Bool {
        !isFormValid || isLoading
    }

    public func submit() {
        guard isFormValid else {
            banner = Banner(style: .error, message: "Enter a valid email address.")
            return
        }
        guard !isLoading else { return }

        let email = self.email
        isLoading = true
        banner = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                try await resetUseCase.execute(email: email)
                await MainActor.run {
                    self.isLoading = false
                    self.banner = Banner(
                        style: .success,
                        message: "If an account exists for this email, you'll receive reset instructions shortly."
                    )
                }
            } catch {
                await MainActor.run {
                    let authError = error as? AuthError ?? .unknown(message: error.localizedDescription)
                    self.banner = Banner(style: .error, message: authError.userMessage)
                    self.isLoading = false
                }
            }
        }
    }
}

private extension PasswordResetViewModel {
    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
