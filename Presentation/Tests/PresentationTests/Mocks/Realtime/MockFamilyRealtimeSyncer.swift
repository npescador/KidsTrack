import Presentation
import Shared

final class MockFamilyRealtimeSyncer: FamilyRealtimeSyncCoordinating {
    private(set) var switchedFamilies: [String] = []
    private(set) var restartCount = 0
    private(set) var stopCount = 0
    var snapshot: FamilyRealtimeSnapshot = .empty

    func switchFamily(to familyId: String) {
        switchedFamilies.append(familyId)
    }

    func restart() {
        restartCount += 1
    }

    func stop() {
        stopCount += 1
    }
}
