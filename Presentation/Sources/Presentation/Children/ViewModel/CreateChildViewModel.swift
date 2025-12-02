import Domain
import Foundation
import Observation
import Shared

@MainActor
@Observable
public final class CreateChildViewModel: Identifiable {
    public let id = UUID()
    public var name: String = ""
    public var grade: String = ""
    public var includeBirthDate = false
    public var birthDate = Date()
    public var selectedColorHex: String?
    public private(set) var error: String?
    public private(set) var isSubmitting = false

    public let family: Family

    private let createChild: CreateChildUseCase

    public init(
        family: Family,
        createChild: CreateChildUseCase
    ) {
        self.family = family
        self.createChild = createChild
    }

    public var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

    public func submit(onCreated: @escaping (Child) -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        error = nil

        let request = CreateChildRequest(
            familyId: family.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: includeBirthDate ? birthDate : nil,
            grade: grade.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            colorHex: selectedColorHex
        )

        Task {
            do {
                let child = try await createChild.execute(request)
                await MainActor.run {
                    self.isSubmitting = false
                    onCreated(child)
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isSubmitting = false
                }
            }
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

#if DEBUG
public extension CreateChildViewModel {
    static func preview(family: Family = .init(id: "fam", name: "Preview", ownerId: "owner")) -> CreateChildViewModel {
        CreateChildViewModel(
            family: family,
            createChild: CreateChildUseCase(repository: PreviewChildrenRepository())
        )
    }
}
#endif
