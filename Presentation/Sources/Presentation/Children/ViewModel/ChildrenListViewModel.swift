import Foundation
import Observation
import Shared

@MainActor
@Observable
public final class ChildrenListViewModel {
    public enum State: Equatable {
        case idle
        case noFamily
        case loading
        case loaded([Child])
    }

    public private(set) var state: State
    public private(set) var familyName: String?

    private var syncer: FamilyRealtimeSyncCoordinating?
    private var observeTask: Task<Void, Never>?
    private var activeFamilyId: String?

    public init(
        activeFamily: Family?,
        familyRealtimeSyncer: FamilyRealtimeSyncCoordinating? = nil
    ) {
        self.activeFamilyId = activeFamily?.id
        self.familyName = activeFamily?.name
        self.syncer = familyRealtimeSyncer
        self.state = activeFamily == nil ? .noFamily : .idle
    }

    deinit {
        Task { @MainActor [weak self] in
            self?.observeTask?.cancel()
        }
    }

    public func start(using syncer: FamilyRealtimeSyncCoordinating?) {
        if let syncer {
            self.syncer = syncer
        }
        restartStreamIfPossible()
    }

    public func updateActiveFamily(_ family: Family?) {
        guard family?.id != activeFamilyId || familyName != family?.name else { return }
        activeFamilyId = family?.id
        familyName = family?.name
        restartStreamIfPossible()
    }
}

private extension ChildrenListViewModel {
    func restartStreamIfPossible() {
        observeTask?.cancel()

        guard let activeFamilyId else {
            state = .noFamily
            return
        }

        guard let syncer else {
            state = .noFamily
            return
        }

        state = .loading

        observeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await snapshot in syncer.observeSnapshot() {
                guard !Task.isCancelled else { return }
                let children = snapshot.children.filter { $0.familyId == activeFamilyId }
                state = .loaded(children)
            }
        }
    }
}
