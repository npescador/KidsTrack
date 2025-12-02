import Foundation

public struct CreateChildRequest: Sendable, Equatable {
    public let familyId: String
    public let name: String
    public let birthDate: Date?
    public let grade: String?
    public let colorHex: String?

    public init(
        familyId: String,
        name: String,
        birthDate: Date? = nil,
        grade: String? = nil,
        colorHex: String? = nil
    ) {
        self.familyId = familyId
        self.name = name
        self.birthDate = birthDate
        self.grade = grade
        self.colorHex = colorHex
    }
}
