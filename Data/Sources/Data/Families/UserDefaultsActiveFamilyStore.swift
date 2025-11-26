import Domain
import Foundation
import Shared

public final class UserDefaultsActiveFamilyStore: ActiveFamilyStoreProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "kidsTrack.activeFamily"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func setActiveFamily(_ family: Family) async {
        do {
            let data = try encoder.encode(family)
            defaults.set(data, forKey: key)
        } catch {
            // Swallow encode failures for now; logging can be added when infrastructure exists.
        }
    }

    public func activeFamily() async -> Family? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(Family.self, from: data)
    }

    public func clearActiveFamily() async {
        defaults.removeObject(forKey: key)
    }
}
