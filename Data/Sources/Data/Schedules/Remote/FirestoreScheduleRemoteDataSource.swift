import Domain
@preconcurrency import FirebaseFirestore
import Shared

public final class FirestoreScheduleRemoteDataSource: ScheduleRemoteDataSourceProtocol, @unchecked Sendable {
    private let db: Firestore

    public init(database: Firestore = .firestore()) {
        self.db = database
    }

    public func createSchoolSlot(_ request: CreateSchoolSlotRequest) async throws -> SchoolSlot {
        let payload = makePayload(from: request)
        let collection = db.collection("families").document(request.familyId).collection("schoolSlots")
        let document = collection.document()
        try await document.setData(payload)
        return SchoolSlot(
            id: document.documentID,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )
    }

    public func updateSchoolSlot(_ request: UpdateSchoolSlotRequest) async throws -> SchoolSlot {
        let payload = makePayload(from: request)
        let document = db.collection("families")
            .document(request.familyId)
            .collection("schoolSlots")
            .document(request.id)
        try await document.setData(payload, merge: true)
        return SchoolSlot(
            id: request.id,
            childId: request.childId,
            weekday: request.weekday,
            startTime: request.startTime,
            endTime: request.endTime,
            subject: request.subject,
            room: request.room
        )
    }

    public func deleteSchoolSlot(id: String, familyId: String) async throws {
        let document = db.collection("families")
            .document(familyId)
            .collection("schoolSlots")
            .document(id)
        try await document.delete()
    }
}

private extension FirestoreScheduleRemoteDataSource {
    func makePayload(from request: CreateSchoolSlotRequest) -> [String: Any] {
        var data: [String: Any] = [
            "childId": request.childId,
            "weekday": request.weekday.rawValue,
            "startTime": encode(request.startTime),
            "endTime": encode(request.endTime),
            "subject": request.subject
        ]

        if let room = request.room, !room.isEmpty {
            data["room"] = room
        }

        return data
    }

    func makePayload(from request: UpdateSchoolSlotRequest) -> [String: Any] {
        var data: [String: Any] = [
            "childId": request.childId,
            "weekday": request.weekday.rawValue,
            "startTime": encode(request.startTime),
            "endTime": encode(request.endTime),
            "subject": request.subject
        ]

        if let room = request.room, !room.isEmpty {
            data["room"] = room
        } else {
            data["room"] = FieldValue.delete()
        }

        return data
    }

    func encode(_ components: DateComponents) -> [String: Any] {
        var payload: [String: Any] = [:]
        if let hour = components.hour {
            payload["hour"] = hour
        }
        if let minute = components.minute {
            payload["minute"] = minute
        }
        return payload
    }
}
