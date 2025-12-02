import Foundation
import Shared

/// In-memory publisher for realtime data used in previews/tests.
public final class InMemoryFamilyRealtimeRemoteDataSource: FamilyRealtimeRemoteDataSourceProtocol, @unchecked Sendable {
    private var childrenByFamily: [String: [Child]] = [:]
    private var schoolSlotsByFamily: [String: [SchoolSlot]] = [:]
    private var activitiesByFamily: [String: [Activity]] = [:]
    private var expensesByFamily: [String: [Expense]] = [:]

    private var childContinuations: [String: [AsyncStream<[Child]>.Continuation]] = [:]
    private var schoolSlotContinuations: [String: [AsyncStream<[SchoolSlot]>.Continuation]] = [:]
    private var activityContinuations: [String: [AsyncStream<[Activity]>.Continuation]] = [:]
    private var expenseContinuations: [String: [AsyncStream<[Expense]>.Continuation]] = [:]

    private let lock = NSLock()

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
