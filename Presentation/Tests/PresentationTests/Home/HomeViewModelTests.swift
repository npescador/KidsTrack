import Domain
import Foundation
import Presentation
import Shared
import Testing

@MainActor
@Suite("HomeViewModel")
struct HomeViewModelTests {
    @Test("Loads families and keeps stored active family while wiring realtime syncer")
    func keepsStoredActiveFamily() async throws {
        let stored = Family(id: "fam-stored", name: "Stored", ownerId: "owner")
        let store = MockActiveFamilyStore()
        await store.setActiveFamily(stored)
        let repository = MockFamilyRepository()
        repository.fetchResult = .success([Family(id: "fam-1", name: "Other", ownerId: "owner")])
        let syncer = MockFamilyRealtimeSyncer()
        let session = MockUserSessionProvider(currentUser: AuthUser(id: "owner", email: "owner@test.com"))
        let viewModel = HomeViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: repository),
            setActiveFamily: SetActiveFamilyUseCase(store: store),
            activeFamilyStore: store,
            sessionProvider: session,
            realtimeSyncer: syncer
        )

        viewModel.start(using: syncer)
        try await waitUntil { viewModel.state == .ready }

        #expect(viewModel.activeFamily?.id == stored.id)
        #expect(syncer.switchedFamilies.contains(stored.id))
    }

    @Test("Selects first family when no stored active family exists")
    func selectsFirstFamilyWhenMissing() async throws {
        let families = [
            Family(id: "fam-1", name: "One", ownerId: "owner"),
            Family(id: "fam-2", name: "Two", ownerId: "owner")
        ]
        let repository = MockFamilyRepository()
        repository.fetchResult = .success(families)
        let store = MockActiveFamilyStore()
        let syncer = MockFamilyRealtimeSyncer()
        let session = MockUserSessionProvider(currentUser: AuthUser(id: "owner", email: "owner@test.com"))
        let viewModel = HomeViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: repository),
            setActiveFamily: SetActiveFamilyUseCase(store: store),
            activeFamilyStore: store,
            sessionProvider: session,
            realtimeSyncer: syncer
        )

        viewModel.start(using: syncer)
        try await waitUntil { viewModel.activeFamily?.id == families.first?.id }

        #expect(store.storedFamily?.id == families.first?.id)
        #expect(syncer.switchedFamilies.first == families.first?.id)
    }

    @Test("Builds today's items only for active family")
    func buildsTodayItemsForActiveFamily() async throws {
        let activeFamily = Family(id: "fam-1", name: "One", ownerId: "owner")
        let repository = MockFamilyRepository()
        repository.fetchResult = .success([activeFamily])
        let store = MockActiveFamilyStore()
        let syncer = MockFamilyRealtimeSyncer()
        let session = MockUserSessionProvider(currentUser: AuthUser(id: "owner", email: "owner@test.com"))
        let viewModel = HomeViewModel(
            getFamilies: GetFamiliesForUserUseCase(repository: repository),
            setActiveFamily: SetActiveFamilyUseCase(store: store),
            activeFamilyStore: store,
            sessionProvider: session,
            realtimeSyncer: syncer
        )

        viewModel.start(using: syncer)
        try await waitUntil { viewModel.state == .ready }

        let todayWeekday = weekdayForToday()
        let activeChild = Child(id: "kid-1", familyId: activeFamily.id, name: "Alex")
        let otherChild = Child(id: "kid-2", familyId: "fam-2", name: "Sam")
        let schoolSlot = SchoolSlot(
            id: "slot-1",
            childId: activeChild.id,
            weekday: todayWeekday,
            startTime: DateComponents(hour: 9, minute: 0),
            endTime: DateComponents(hour: 10, minute: 0),
            subject: "Math"
        )
        let activity = Activity(
            id: "act-1",
            childId: otherChild.id,
            name: "Piano",
            category: .music,
            weekdays: [todayWeekday],
            startTime: DateComponents(hour: 11, minute: 0),
            endTime: DateComponents(hour: 12, minute: 0),
            location: "Room A",
            recurringCost: nil,
            recurrence: nil
        )

        syncer.emit(
            FamilyRealtimeSnapshot(
                children: [activeChild, otherChild],
                schoolSlots: [schoolSlot],
                activities: [activity],
                expenses: []
            )
        )

        try await waitUntil { viewModel.todayItems.count == 1 }
        #expect(viewModel.todayItems.first?.title == "Math")
        #expect(viewModel.todayItems.first?.childName == "Alex")
    }
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    condition: @escaping @MainActor () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while clock.now < deadline {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: 20_000_000)
    }

    throw HomeWaitError.timeout
}

private func weekdayForToday(calendar: Calendar = .current) -> Weekday {
    switch calendar.component(.weekday, from: Date()) {
    case 1: return .sunday
    case 2: return .monday
    case 3: return .tuesday
    case 4: return .wednesday
    case 5: return .thursday
    case 6: return .friday
    default: return .saturday
    }
}

enum HomeWaitError: Error {
    case timeout
}
