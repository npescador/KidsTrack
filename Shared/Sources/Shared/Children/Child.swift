import Foundation

public struct Child: Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let familyId: String
    public let name: String
    public let birthDate: Date?
    public let grade: String?
    public let colorHex: String?

    public init(
        id: String,
        familyId: String,
        name: String,
        birthDate: Date? = nil,
        grade: String? = nil,
        colorHex: String? = nil
    ) {
        self.id = id
        self.familyId = familyId
        self.name = name
        self.birthDate = birthDate
        self.grade = grade
        self.colorHex = colorHex
    }
}
