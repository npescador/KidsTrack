import Shared

public protocol ActiveFamilyStoreProtocol: Sendable {
    func setActiveFamily(_ family: Family) async
    func activeFamily() async -> Family?
    func clearActiveFamily() async
}
