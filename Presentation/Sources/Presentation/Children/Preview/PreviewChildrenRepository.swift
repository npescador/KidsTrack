import Domain
import Foundation
import Shared

#if DEBUG
public struct PreviewChildrenRepository: ChildrenRepositoryProtocol {
    public init() {}

    public func createChild(_ request: CreateChildRequest) async throws -> Child {
        Child(
            id: UUID().uuidString,
            familyId: request.familyId,
            name: request.name,
            birthDate: request.birthDate,
            grade: request.grade,
            colorHex: request.colorHex
        )
    }

    public func updateChild(_ request: UpdateChildRequest) async throws -> Child {
        Child(
            id: request.id,
            familyId: request.familyId,
            name: request.name,
            birthDate: request.birthDate,
            grade: request.grade,
            colorHex: request.colorHex
        )
    }
}
#endif
