import Domain
import Foundation
import Observation
import Shared

@MainActor
@Observable
public final class HomeViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case ready
        case error(String)
    }

    public struct TodayItem: Identifiable, Equatable {
        public enum Kind {
            case schoolSlot
            case activity
        }

        public let id: String
        public let title: String
        public let childName: String
        public let kind: Kind
        public let startDate: Date?
        public let endDate: Date?
        public let location: String?
        public let weekday: Weekday
        public let timeRange: String
    }

    public private(set) var state: State = .idle
    public private(set) var activeFamily: Family?
    public private(set) var families: [Family] = []
    public private(set) var children: [Child] = []
    public private(set) var todayItems: [TodayItem] = []

    public var hasFamily: Bool { activeFamily != nil }
    public var hasChildren: Bool { !children.isEmpty }
    public var activeFamilyName: String? { activeFamily?.name }

    private let getFamilies: GetFamiliesForUserUseCase
    private let setActiveFamily: SetActiveFamilyUseCase
    private let activeFamilyStore: ActiveFamilyStoreProtocol
    private let sessionProvider: UserSessionProviding
    private var realtimeSyncer: FamilyRealtimeSyncCoordinating?
    private var observeTask: Task<Void, Never>?

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

    public func start(using syncer: FamilyRealtimeSyncCoordinating?) {
        if let syncer {
            self.realtimeSyncer = syncer
        }
        Task { [weak self] in
            await self?.refreshStoredFamily()
        }
        loadFamiliesIfNeeded()
        restartSnapshotStreamIfPossible()
    }

    public func loadFamiliesIfNeeded() {
        switch state {
        case .idle, .error:
            loadFamilies()
        case .loading, .ready:
            Task { [weak self] in
                await self?.refreshStoredFamily()
            }
            return
        }
    }

    public func refreshActiveFamily() {
        Task { [weak self] in
            await self?.refreshStoredFamily()
        }
    }
}

private extension HomeViewModel {
    func loadFamilies() {
        guard let userId = sessionProvider.currentUser?.id else {
            state = .error("home.error.session".localizedText())
            return
        }

        state = .loading

        Task { [weak self] in
            guard let self else { return }
            let storedFamily = await activeFamilyStore.activeFamily()
            await MainActor.run {
                self.activeFamily = storedFamily
            }

            do {
                let families = try await getFamilies.execute(userId: userId)
                await MainActor.run {
                    self.families = families
                    self.resolveActiveFamily(from: families, stored: storedFamily)
                    self.state = .ready
                }
                await MainActor.run {
                    self.restartSnapshotStreamIfPossible()
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func resolveActiveFamily(from families: [Family], stored: Family?) {
        if let stored {
            setActiveFamily(stored)
            return
        }

        if let first = families.first {
            setActiveFamily(first)
            return
        }

        setActiveFamily(nil)
    }

    func refreshStoredFamily() async {
        let stored = await activeFamilyStore.activeFamily()
        await MainActor.run {
            if stored?.id != self.activeFamily?.id {
                self.setActiveFamily(stored)
                self.restartSnapshotStreamIfPossible()
            }
        }
    }

    func setActiveFamily(_ family: Family?) {
        activeFamily = family
        observeTask?.cancel()

        guard let family else {
            realtimeSyncer?.stop()
            children = []
            todayItems = []
            return
        }

        realtimeSyncer?.switchFamily(to: family.id)
        Task {
            await setActiveFamily.execute(family)
        }
    }

    func restartSnapshotStreamIfPossible() {
        observeTask?.cancel()

        guard let syncer = realtimeSyncer, let familyId = activeFamily?.id else {
            children = []
            todayItems = []
            return
        }

        observeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await snapshot in syncer.observeSnapshot() {
                guard !Task.isCancelled else { return }
                handleSnapshot(snapshot, familyId: familyId)
            }
        }
    }

    func handleSnapshot(_ snapshot: FamilyRealtimeSnapshot, familyId: String) {
        let scopedChildren = snapshot.children.filter { $0.familyId == familyId }
        children = scopedChildren
        todayItems = Self.buildTodayItems(
            snapshot: snapshot,
            familyId: familyId,
            children: scopedChildren,
            calendar: .current
        )
    }
}

private extension HomeViewModel {
    static func buildTodayItems(
        snapshot: FamilyRealtimeSnapshot,
        familyId: String,
        children: [Child],
        calendar: Calendar
    ) -> [TodayItem] {
        guard let weekday = weekday(for: Date(), calendar: calendar) else { return [] }

        let childrenById = Dictionary(uniqueKeysWithValues: children.map { ($0.id, $0) })
        var items: [TodayItem] = []

        let schoolItems = snapshot.schoolSlots
            .filter { childrenById[$0.childId]?.familyId == familyId && $0.weekday == weekday }
            .compactMap { slot -> TodayItem in
                let start = date(from: slot.startTime, on: Date(), calendar: calendar)
                let end = date(from: slot.endTime, on: Date(), calendar: calendar)
                return TodayItem(
                    id: slot.id,
                    title: slot.subject,
                    childName: childrenById[slot.childId]?.name ?? "",
                    kind: .schoolSlot,
                    startDate: start,
                    endDate: end,
                    location: slot.room,
                    weekday: weekday,
                    timeRange: formatTimeRange(start: start, end: end, calendar: calendar)
                )
            }

        let activityItems = snapshot.activities
            .filter { childrenById[$0.childId]?.familyId == familyId && $0.weekdays.contains(weekday) }
            .compactMap { activity -> TodayItem in
                let start = date(from: activity.startTime, on: Date(), calendar: calendar)
                let end = date(from: activity.endTime, on: Date(), calendar: calendar)
                return TodayItem(
                    id: activity.id,
                    title: activity.name,
                    childName: childrenById[activity.childId]?.name ?? "",
                    kind: .activity,
                    startDate: start,
                    endDate: end,
                    location: activity.location,
                    weekday: weekday,
                    timeRange: formatTimeRange(start: start, end: end, calendar: calendar)
                )
            }

        items.append(contentsOf: schoolItems)
        items.append(contentsOf: activityItems)

        return items.sorted {
            ($0.startDate ?? .distantFuture, $0.title) < ($1.startDate ?? .distantFuture, $1.title)
        }
    }

    static func weekday(for date: Date, calendar: Calendar) -> Weekday? {
        switch calendar.component(.weekday, from: date) {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }

    static func date(from components: DateComponents, on baseDate: Date, calendar: Calendar) -> Date? {
        var merged = components
        let parts = calendar.dateComponents([.year, .month, .day], from: baseDate)
        merged.year = parts.year
        merged.month = parts.month
        merged.day = parts.day
        return calendar.date(from: merged)
    }

    static func formatTimeRange(start: Date?, end: Date?, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HHmm", options: 0, locale: formatter.locale)

        let startText = start.map { formatter.string(from: $0) } ?? "—"
        let endText = end.map { formatter.string(from: $0) } ?? "—"

        if startText == "—", endText == "—" {
            return "—"
        }

        return "\(startText) • \(endText)"
    }
}

#if DEBUG
public extension HomeViewModel {
    static func preview(activeFamily: Family? = nil) -> HomeViewModel {
        HomeViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: PreviewFamilyRepository()),
            setActiveFamily: SetActiveFamilyUseCase(store: PreviewActiveFamilyStore()),
            activeFamilyStore: PreviewActiveFamilyStore(),
            sessionProvider: PreviewUserSessionProvider(
                currentUser: .init(
                    id: "preview-owner",
                    email: "demo@kidstrack.app"
                )
            ),
            realtimeSyncer: nil
        )
    }
}
#endif
