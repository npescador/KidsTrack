import Domain
import Foundation
import Shared

/// In-memory publisher for realtime data used in previews/tests.
public final class InMemoryFamilyRealtimeRemoteDataSource: FamilyRealtimeRemoteDataSourceProtocol, @unchecked Sendable {
    fileprivate var childrenByFamily: [String: [Child]] = [:]
    fileprivate var schoolSlotsByFamily: [String: [SchoolSlot]] = [:]
    fileprivate var activitiesByFamily: [String: [Activity]] = [:]
    fileprivate var expensesByFamily: [String: [Expense]] = [:]

    fileprivate var childContinuations: [String: [AsyncStream<[Child]>.Continuation]] = [:]
    fileprivate var schoolSlotContinuations: [String: [AsyncStream<[SchoolSlot]>.Continuation]] = [:]
    fileprivate var activityContinuations: [String: [AsyncStream<[Activity]>.Continuation]] = [:]
    fileprivate var expenseContinuations: [String: [AsyncStream<[Expense]>.Continuation]] = [:]

    fileprivate let lock = NSLock()

    public init() {}

    public func observeChildren(for familyId: String) -> AsyncStream<[Child]> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            lock.lock()
            let current = childrenByFamily[familyId, default: []]
            continuation.yield(current)
            var list = childContinuations[familyId, default: []]
            list.append(continuation)
            childContinuations[familyId] = list
            lock.unlock()
        }
    }

    public func observeSchoolSlots(for familyId: String) -> AsyncStream<[SchoolSlot]> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            lock.lock()
            let current = schoolSlotsByFamily[familyId, default: []]
            continuation.yield(current)
            var list = schoolSlotContinuations[familyId, default: []]
            list.append(continuation)
            schoolSlotContinuations[familyId] = list
            lock.unlock()
        }
    }

    public func observeActivities(for familyId: String) -> AsyncStream<[Activity]> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            lock.lock()
            let current = activitiesByFamily[familyId, default: []]
            continuation.yield(current)
            var list = activityContinuations[familyId, default: []]
            list.append(continuation)
            activityContinuations[familyId] = list
            lock.unlock()
        }
    }

    public func observeExpenses(for familyId: String) -> AsyncStream<[Expense]> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            lock.lock()
            let current = expensesByFamily[familyId, default: []]
            continuation.yield(current)
            var list = expenseContinuations[familyId, default: []]
            list.append(continuation)
            expenseContinuations[familyId] = list
            lock.unlock()
        }
    }

    public func updateChildren(_ children: [Child], for familyId: String) {
        lock.lock()
        childrenByFamily[familyId] = children
        let targets = childContinuations[familyId, default: []]
        lock.unlock()
        targets.forEach { $0.yield(children) }
    }

    public func updateSchoolSlots(_ slots: [SchoolSlot], for familyId: String) {
        lock.lock()
        schoolSlotsByFamily[familyId] = slots
        let targets = schoolSlotContinuations[familyId, default: []]
        lock.unlock()
        targets.forEach { $0.yield(slots) }
    }

    public func updateActivities(_ activities: [Activity], for familyId: String) {
        lock.lock()
        activitiesByFamily[familyId] = activities
        let targets = activityContinuations[familyId, default: []]
        lock.unlock()
        targets.forEach { $0.yield(activities) }
    }

    public func updateExpenses(_ expenses: [Expense], for familyId: String) {
        lock.lock()
        expensesByFamily[familyId] = expenses
        let targets = expenseContinuations[familyId, default: []]
        lock.unlock()
        targets.forEach { $0.yield(expenses) }
    }
}

extension InMemoryFamilyRealtimeRemoteDataSource: ChildrenRemoteDataSourceProtocol {
    public func createChild(_ request: CreateChildRequest) async throws -> Child {
        let newChild = Child(
            id: UUID().uuidString,
            familyId: request.familyId,
            name: request.name,
            birthDate: request.birthDate,
            grade: request.grade,
            colorHex: request.colorHex
        )

        let (children, targets) = lock.withLock {
            var children = childrenByFamily[request.familyId, default: []]
            children.append(newChild)
            childrenByFamily[request.familyId] = children
            let targets = childContinuations[request.familyId, default: []]
            return (children, targets)
        }
        targets.forEach { $0.yield(children) }
        return newChild
    }

    public func updateChild(_ request: UpdateChildRequest) async throws -> Child {
        let updatedChild = Child(
            id: request.id,
            familyId: request.familyId,
            name: request.name,
            birthDate: request.birthDate,
            grade: request.grade,
            colorHex: request.colorHex
        )

        let (children, targets) = lock.withLock {
            var children = childrenByFamily[request.familyId, default: []]
            if let index = children.firstIndex(where: { $0.id == request.id }) {
                children[index] = updatedChild
            } else {
                children.append(updatedChild)
            }
            childrenByFamily[request.familyId] = children
            let targets = childContinuations[request.familyId, default: []]
            return (children, targets)
        }

        targets.forEach { $0.yield(children) }
        return updatedChild
    }

    public func deleteChild(id: String, familyId: String) async throws {
        let (children, targets) = lock.withLock {
            var children = childrenByFamily[familyId, default: []]
            children.removeAll { $0.id == id }
            childrenByFamily[familyId] = children
            let targets = childContinuations[familyId, default: []]
            return (children, targets)
        }
        targets.forEach { $0.yield(children) }
    }
}

extension InMemoryFamilyRealtimeRemoteDataSource: ScheduleRemoteDataSourceProtocol {
    public func createSchoolSlot(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot {
        let slot = SchoolSlot(
            id: UUID().uuidString,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )

        let (slots, targets) = lock.withLock {
            var slots = schoolSlotsByFamily[request.familyId, default: []]
            slots.append(slot)
            schoolSlotsByFamily[request.familyId] = slots
            let targets = schoolSlotContinuations[request.familyId, default: []]
            return (slots, targets)
        }
        targets.forEach { $0.yield(slots) }
        return slot
    }

    public func updateSchoolSlot(_ request: UpdateSchoolSlotRequest) async throws -> SchoolSlot {
        let slot = SchoolSlot(
            id: request.id,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )

        let (slots, targets) = lock.withLock {
            var slots = schoolSlotsByFamily[request.familyId, default: []]
            if let index = slots.firstIndex(where: { $0.id == request.id }) {
                slots[index] = slot
            } else {
                slots.append(slot)
            }
            schoolSlotsByFamily[request.familyId] = slots
            let targets = schoolSlotContinuations[request.familyId, default: []]
            return (slots, targets)
        }
        targets.forEach { $0.yield(slots) }
        return slot
    }

    public func deleteSchoolSlot(id: String, familyId: String) async throws {
        let (slots, targets) = lock.withLock {
            var slots = schoolSlotsByFamily[familyId, default: []]
            slots.removeAll { $0.id == id }
            schoolSlotsByFamily[familyId] = slots
            let targets = schoolSlotContinuations[familyId, default: []]
            return (slots, targets)
        }
        targets.forEach { $0.yield(slots) }
    }
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
