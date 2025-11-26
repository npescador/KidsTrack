import Domain
import Observation
import Shared

@MainActor
@Observable
public final class CreateFamilyViewModel {
    public struct Banner: Equatable {
        public let message: String
        public let isError: Bool

        public init(message: String, isError: Bool = false) {
            self.message = message
            self.isError = isError
        }
    }

    public var name = ""
    public var isLoading = false
    public var banner: Banner?
    public var createdFamily: Family?

    public var isCreateDisabled: Bool {
        isLoading || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let createFamilyUseCase: CreateFamilyUseCase
    private let sessionProvider: UserSessionProviding

    public init(
        createFamilyUseCase: CreateFamilyUseCase,
        sessionProvider: UserSessionProviding
    ) {
        self.createFamilyUseCase = createFamilyUseCase
        self.sessionProvider = sessionProvider
    }

    public func createFamily() {
        guard !isCreateDisabled else {
            banner = Banner(message: "Family name is required.", isError: true)
            return
        }

        guard let ownerId = sessionProvider.currentUser?.id else {
            banner = Banner(message: "You must be signed in to create a family.", isError: true)
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let createFamilyUseCase = self.createFamilyUseCase

        isLoading = true
        banner = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let family = try await createFamilyUseCase.execute(name: trimmedName, ownerId: ownerId)
                self.handleSuccess(family)
            } catch {
                self.handleFailure(error)
            }
        }
    }
}

private extension CreateFamilyViewModel {
    @MainActor
    func handleSuccess(_ family: Family) {
        createdFamily = family
        name = ""
        isLoading = false
        banner = Banner(message: "Family created successfully.")
    }

    @MainActor
    func handleFailure(_ error: Error) {
        let message: String
        if let authError = error as? AuthError {
            message = authError.userMessage
        } else {
            message = error.localizedDescription
        }
        banner = Banner(message: message, isError: true)
        isLoading = false
    }
}

#if DEBUG
extension CreateFamilyViewModel {
    public static func preview() -> CreateFamilyViewModel {
        CreateFamilyViewModel(
            createFamilyUseCase: CreateFamilyUseCase(
                repository: PreviewFamilyRepository(),
                activeStore: PreviewActiveFamilyStore()
            ),
            sessionProvider: PreviewUserSessionProvider()
        )
    }
}
#endif
