import Domain
import Foundation
import Observation
import Shared

@MainActor
public protocol FamilyRealtimeSyncCoordinating: Observable, AnyObject {
    var snapshot: FamilyRealtimeSnapshot { get }
    func switchFamily(to familyId: String)
    func restart()
    func stop()
    func observeSnapshot() -> AsyncStream<FamilyRealtimeSnapshot>
}

@MainActor
@Observable
public final class FamilyRealtimeSyncCoordinator: FamilyRealtimeSyncCoordinating {
    public private(set) var snapshot: FamilyRealtimeSnapshot = .empty

    private let observeRealtime: ObserveFamilyRealtimeUseCase
    private var currentFamilyId: String?
    private var tasks: [Task<Void, Never>] = []
    private var snapshotContinuations: [UUID: AsyncStream<FamilyRealtimeSnapshot>.Continuation] = [:]

    public init(observeRealtime: ObserveFamilyRealtimeUseCase) {
        self.observeRealtime = observeRealtime
    }

    public func switchFamily(to familyId: String) {
        guard currentFamilyId != familyId else {
            restart()
            return
        }
        currentFamilyId = familyId
        bindStreams(for: familyId, resetSnapshot: true)
    }

    public func restart() {
        guard let familyId = currentFamilyId else { return }
        bindStreams(for: familyId, resetSnapshot: false)
    }

    public func stop() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        currentFamilyId = nil
        snapshot = .empty
        broadcastSnapshot()
    }

    public func observeSnapshot() -> AsyncStream<FamilyRealtimeSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            Task { @MainActor [weak self] in
                self?.snapshotContinuations[id] = continuation
                continuation.yield(self?.snapshot ?? .empty)
            }

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.snapshotContinuations[id] = nil
                }
            }
        }
    }
}

private extension FamilyRealtimeSyncCoordinator {
    func bindStreams(for familyId: String, resetSnapshot: Bool) {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        if resetSnapshot {
            snapshot = .empty
            broadcastSnapshot()
        }
        currentFamilyId = familyId
        let streams = observeRealtime.execute(familyId: familyId)

        let childTask = Task { [weak self] in
            guard let self else { return }
            for await children in streams.children {
                await self.updateSnapshot { snapshot in
                    snapshot.children = Self.uniqueById(children)
                }
            }
        }

        let schoolSlotsTask = Task { [weak self] in
            guard let self else { return }
            for await slots in streams.schoolSlots {
                await self.updateSnapshot { snapshot in
                    snapshot.schoolSlots = Self.uniqueById(slots)
                }
            }
        }

        let activitiesTask = Task { [weak self] in
            guard let self else { return }
            for await activities in streams.activities {
                await self.updateSnapshot { snapshot in
                    snapshot.activities = Self.uniqueById(activities)
                }
            }
        }

        let expensesTask = Task { [weak self] in
            guard let self else { return }
            for await expenses in streams.expenses {
                await self.updateSnapshot { snapshot in
                    snapshot.expenses = Self.uniqueById(expenses)
                }
            }
        }

        tasks = [childTask, schoolSlotsTask, activitiesTask, expensesTask]
    }

    func updateSnapshot(_ mutate: (inout FamilyRealtimeSnapshot) -> Void) async {
        var updated = snapshot
        mutate(&updated)
        guard updated != snapshot else { return }
        snapshot = updated
        broadcastSnapshot()
    }

    static func uniqueById<T: Identifiable>(_ values: [T]) -> [T] where T.ID: Hashable {
        var seen: Set<T.ID> = []
        return values.filter { seen.insert($0.id).inserted }
    }

    func broadcastSnapshot() {
        snapshotContinuations.values.forEach { $0.yield(snapshot) }
    }
}
