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
    public private(set) var isEditing: Bool

    public let family: Family

    private let createChild: CreateChildUseCase
    private let updateChild: UpdateChildUseCase?
    private let existingChild: Child?

    public init(
        family: Family,
        createChild: CreateChildUseCase,
        updateChild: UpdateChildUseCase? = nil,
        existingChild: Child? = nil
    ) {
        self.family = family
        self.createChild = createChild
        self.updateChild = updateChild
        self.existingChild = existingChild
        self.isEditing = existingChild != nil
        if let existing = existingChild {
            self.name = existing.name
            self.grade = existing.grade ?? ""
            if let birthDate = existing.birthDate {
                includeBirthDate = true
                self.birthDate = birthDate
            }
            self.selectedColorHex = existing.colorHex
        }
    }

    public var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

    public func submit(onSaved: @escaping (Child) -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        error = nil

        Task {
            do {
                let child: Child
                if let existingChild, let updateChild {
                    let request = UpdateChildRequest(
                        id: existingChild.id,
                        familyId: family.id,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        birthDate: includeBirthDate ? birthDate : nil,
                        grade: grade.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                        colorHex: selectedColorHex
                    )
                    child = try await updateChild.execute(request)
                } else {
                    let request = CreateChildRequest(
                        familyId: family.id,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        birthDate: includeBirthDate ? birthDate : nil,
                        grade: grade.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                        colorHex: selectedColorHex
                    )
                    child = try await createChild.execute(request)
                }
                await MainActor.run {
                    self.isSubmitting = false
                    onSaved(child)
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
            createChild: CreateChildUseCase(repository: PreviewChildrenRepository()),
            updateChild: UpdateChildUseCase(repository: PreviewChildrenRepository())
        )
    }
}
#endif
