import Domain
import Shared

final class MockActiveFamilyStore: ActiveFamilyStoreProtocol, @unchecked Sendable {
    private(set) var storedFamily: Family?

    func setActiveFamily(_ family: Family) async {
        storedFamily = family
    }

    func activeFamily() async -> Family? {
        storedFamily
    }

    func clearActiveFamily() async {
        storedFamily = nil
    }
}
