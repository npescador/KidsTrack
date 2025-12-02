import Domain
import Foundation
import Observation
import Shared

@MainActor
@Observable
public final class FamilySelectionViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case loaded([Family])
        case error(String)
    }

    public var state: State = .idle
    public var activeFamily: Family?
    public var banner: String?
    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    private let getFamilies: GetFamiliesForUserUseCase
    private let setActiveFamily: SetActiveFamilyUseCase
    private let activeFamilyStore: ActiveFamilyStoreProtocol
    private let sessionProvider: UserSessionProviding
    private let realtimeSyncer: FamilyRealtimeSyncCoordinating?

    public var currentUserEmail: String? { sessionProvider.currentUser?.email }
    public var currentUserId: String? { sessionProvider.currentUser?.id }

    public init(
        getFamilies: GetFamiliesForUserUseCase,
        setActiveFamily: SetActiveFamilyUseCase,
        activeFamilyStore: ActiveFamilyStoreProtocol,
        sessionProvider: UserSessionProviding,
        realtimeSyncer: FamilyRealtimeSyncCoordinating? = nil
    ) {
        self.getFamilies = getFamilies
        self.setActiveFamily = setActiveFamily
        self.activeFamilyStore = activeFamilyStore
        self.sessionProvider = sessionProvider
        self.realtimeSyncer = realtimeSyncer
    }

    public func load() {
        guard let userId = sessionProvider.currentUser?.id else {
            state = .error("You must be signed in to load families.")
            return
        }

        state = .loading
        banner = nil

        Task { [weak self] in
            guard let self else { return }
            let current = await activeFamilyStore.activeFamily()
            await MainActor.run {
                self.activeFamily = current
            }
            do {
                let families = try await getFamilies.execute(userId: userId)
                await MainActor.run {
                    self.state = .loaded(families)
                    // Keep active family if already set, else pick first when available.
                    if self.activeFamily == nil, let first = families.first {
                        self.select(first)
                    } else if let activeFamily {
                        self.realtimeSyncer?.switchFamily(to: activeFamily.id)
                    }
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    public func select(_ family: Family) {
        activeFamily = family
        realtimeSyncer?.switchFamily(to: family.id)
        Task {
            await setActiveFamily.execute(family)
        }
    }

    public func handleCreated(_ family: Family) {
        switch state {
        case .loaded(var families):
            if !families.contains(where: { $0.id == family.id }) {
                families.append(family)
            }
            state = .loaded(families)
        default:
            state = .loaded([family])
        }
        setBanner("families.banner.created".localized())
        select(family)
    }

    public func handleAccepted(_ family: Family) {
        switch state {
        case .loaded(var families):
            if !families.contains(where: { $0.id == family.id }) {
                families.append(family)
            }
            state = .loaded(families)
        default:
            state = .loaded([family])
        }
        select(family)
    }

    private func setBanner(_ message: LocalizedStringResource, duration: Duration = .seconds(3)) {
        let rendered = String(localized: message)
        banner = rendered
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: duration)
            if self?.banner == rendered {
                self?.banner = nil
            }
        }
    }
}
