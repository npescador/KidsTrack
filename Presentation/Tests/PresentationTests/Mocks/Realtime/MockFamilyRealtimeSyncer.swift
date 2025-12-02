import Observation
import Presentation
import Shared

@MainActor
@Observable
final class MockFamilyRealtimeSyncer: FamilyRealtimeSyncCoordinating {
    private(set) var switchedFamilies: [String] = []
    private(set) var restartCount = 0
    private(set) var stopCount = 0
    var snapshot: FamilyRealtimeSnapshot = .empty
    private var snapshotContinuation: AsyncStream<FamilyRealtimeSnapshot>.Continuation?

    func switchFamily(to familyId: String) {
        switchedFamilies.append(familyId)
    }

    func restart() {
        restartCount += 1
    }

    func stop() {
        stopCount += 1
    }

    func observeSnapshot() -> AsyncStream<FamilyRealtimeSnapshot> {
        AsyncStream { continuation in
            Task { @MainActor [weak self] in
                self?.snapshotContinuation = continuation
                continuation.yield(self?.snapshot ?? .empty)
            }

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.snapshotContinuation = nil
                }
            }
        }
    }

    func emit(_ snapshot: FamilyRealtimeSnapshot) {
        self.snapshot = snapshot
        snapshotContinuation?.yield(snapshot)
    }
}
