@preconcurrency import FirebaseFirestore
import Shared

/// Firestore-backed realtime data source for family-scoped collections.
public final class FirestoreFamilyRealtimeRemoteDataSource: FamilyRealtimeRemoteDataSourceProtocol,
                                                                @unchecked Sendable {
    private let db: Firestore

    public init(database: Firestore = .firestore()) {
        self.db = database
    }

    public func observeChildren(for familyId: String) -> AsyncStream<[Child]> {
        observeCollection(
            db.collection("families").document(familyId).collection("children")
        ) { snapshot in
            snapshot.documents.compactMap { Self.decodeChild($0, fallbackFamilyId: familyId) }
        }
    }

    public func observeSchoolSlots(for familyId: String) -> AsyncStream<[SchoolSlot]> {
        observeCollection(
            db.collection("families").document(familyId).collection("schoolSlots")
        ) { snapshot in
            snapshot.documents.compactMap { Self.decodeSchoolSlot($0) }
        }
    }

    public func observeActivities(for familyId: String) -> AsyncStream<[Activity]> {
        observeCollection(
            db.collection("families").document(familyId).collection("activities")
        ) { snapshot in
            snapshot.documents.compactMap { Self.decodeActivity($0) }
        }
    }

    public func observeExpenses(for familyId: String) -> AsyncStream<[Expense]> {
        observeCollection(
            db.collection("families").document(familyId).collection("expenses")
        ) { snapshot in
            snapshot.documents.compactMap { Self.decodeExpense($0) }
        }
    }
}

private extension FirestoreFamilyRealtimeRemoteDataSource {
    func observeCollection<Value>(
        _ collection: CollectionReference,
        map: @escaping (QuerySnapshot) -> [Value]
    ) -> AsyncStream<[Value]> {
        AsyncStream { continuation in
            let token = ListenerToken(
                collection.addSnapshotListener { snapshot, error in
                    if let error {
                        // Surface an empty payload so callers can clear stale data on failures.
                        continuation.yield([])
                        #if DEBUG
                        print("Firestore realtime error: \(error.localizedDescription)")
                        #endif
                        return
                    }
                    guard let snapshot else { return }
                    continuation.yield(map(snapshot))
                }
            )

            continuation.onTermination = { _ in
                token.cancel()
            }
        }
    }

    static func decodeChild(_ document: QueryDocumentSnapshot, fallbackFamilyId: String) -> Child? {
        let data = document.data()
        guard let name = data["name"] as? String else { return nil }
        let familyId = data["familyId"] as? String ?? fallbackFamilyId
        let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
        let grade = data["grade"] as? String
        let colorHex = data["colorHex"] as? String
        return Child(
            id: document.documentID,
            familyId: familyId,
            name: name,
            birthDate: birthDate,
            grade: grade,
            colorHex: colorHex
        )
    }

    static func decodeSchoolSlot(_ document: QueryDocumentSnapshot) -> SchoolSlot? {
        let data = document.data()
        guard
            let childId = data["childId"] as? String,
            let weekdayRaw = data["weekday"] as? String,
            let weekday = Weekday(rawValue: weekdayRaw),
            let startTime = decodeDateComponents(data["startTime"]),
            let endTime = decodeDateComponents(data["endTime"]),
            let subject = data["subject"] as? String
        else { return nil }

        let room = data["room"] as? String
        return SchoolSlot(
            id: document.documentID,
            childId: childId,
            weekday: weekday,
            startTime: startTime,
            endTime: endTime,
            subject: subject,
            room: room
        )
    }

    static func decodeActivity(_ document: QueryDocumentSnapshot) -> Activity? {
        let data = document.data()
        guard
            let childId = data["childId"] as? String,
            let name = data["name"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = ActivityCategory(rawValue: categoryRaw),
            let weekdayRaws = data["weekdays"] as? [String],
            let startTime = decodeDateComponents(data["startTime"]),
            let endTime = decodeDateComponents(data["endTime"])
        else { return nil }

        let weekdays = weekdayRaws.compactMap(Weekday.init(rawValue:))
        guard !weekdays.isEmpty else { return nil }

        let location = data["location"] as? String
        let recurringCost = data["recurringCost"] as? Double
        let recurrence = (data["recurrence"] as? String).flatMap(Recurrence.init(rawValue:))

        return Activity(
            id: document.documentID,
            childId: childId,
            name: name,
            category: category,
            weekdays: weekdays,
            startTime: startTime,
            endTime: endTime,
            location: location,
            recurringCost: recurringCost,
            recurrence: recurrence
        )
    }

    static func decodeExpense(_ document: QueryDocumentSnapshot) -> Expense? {
        let data = document.data()
        guard
            let childId = data["childId"] as? String,
            let amount = data["amount"] as? Double,
            let concept = data["concept"] as? String,
            let date = decodeDate(data["date"])
        else { return nil }

        let activityId = data["activityId"] as? String

        return Expense(
            id: document.documentID,
            childId: childId,
            activityId: activityId,
            amount: amount,
            concept: concept,
            date: date
        )
    }

    static func decodeDateComponents(_ value: Any?) -> DateComponents? {
        if let dict = value as? [String: Any] {
            let hour = dict["hour"] as? Int
            let minute = dict["minute"] as? Int
            if hour != nil || minute != nil {
                return DateComponents(hour: hour, minute: minute)
            }
        }
        if let timestamp = value as? Timestamp {
            let date = timestamp.dateValue()
            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
            if comps.hour != nil || comps.minute != nil {
                return comps
            }
        }
        return nil
    }

    static func decodeDate(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }
        if let seconds = value as? TimeInterval {
            return Date(timeIntervalSince1970: seconds)
        }
        return nil
    }
}

private final class ListenerToken: @unchecked Sendable {
    private let registration: ListenerRegistration

    init(_ registration: ListenerRegistration) {
        self.registration = registration
    }

    func cancel() {
        registration.remove()
    }
}
