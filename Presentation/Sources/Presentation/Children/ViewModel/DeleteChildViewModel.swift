import Domain
import Foundation
import Observation
import Shared
import SwiftUI

@MainActor
@Observable
public final class DeleteChildViewModel: Identifiable {
    public typealias Identifier = UUID
    public let id = UUID()
    public private(set) var isDeleting = false
    public private(set) var error: String?

    public let family: Family
    public let child: Child

    private let deleteChild: DeleteChildUseCase

    public init(
        family: Family,
        child: Child,
        deleteChild: DeleteChildUseCase
    ) {
        self.family = family
        self.child = child
        self.deleteChild = deleteChild
    }

    public func delete(onDeleted: @escaping () -> Void) {
        guard !isDeleting else { return }
        isDeleting = true
        error = nil

        Task {
            do {
                try await deleteChild.execute(id: child.id, familyId: family.id)
                await MainActor.run {
                    self.isDeleting = false
                    onDeleted()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isDeleting = false
                }
            }
        }
    }
}

#if DEBUG
public extension DeleteChildViewModel {
    static func preview(
        family: Family = .init(id: "fam", name: "Preview", ownerId: "owner"),
        child: Child = .init(id: "child", familyId: "fam", name: "Alex")
    ) -> DeleteChildViewModel {
        DeleteChildViewModel(
            family: family,
            child: child,
            deleteChild: DeleteChildUseCase(repository: PreviewChildrenRepository())
        )
    }
}
#endif
