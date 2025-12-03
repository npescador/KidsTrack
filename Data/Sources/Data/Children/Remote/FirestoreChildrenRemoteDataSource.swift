import Domain
@preconcurrency import FirebaseFirestore
import Shared

public final class FirestoreChildrenRemoteDataSource: ChildrenRemoteDataSourceProtocol, @unchecked Sendable {
    private let db: Firestore

    public init(database: Firestore = .firestore()) {
        db = database
    }

    public func createChild(_ request: CreateChildRequest) async throws -> Child {
        let data = makePayload(from: request)
        let collection = db.collection("families").document(request.familyId).collection("children")
        let document = collection.document()
        try await document.setData(data)
        return Child(
            id: document.documentID,
            familyId: request.familyId,
            name: request.name,
            birthDate: request.birthDate,
            grade: request.grade,
            colorHex: request.colorHex
        )
    }

    public func updateChild(_ request: UpdateChildRequest) async throws -> Child {
        let data = makePayload(from: request)
        let document = db.collection("families")
            .document(request.familyId)
            .collection("children")
            .document(request.id)
        try await document.setData(data, merge: true)
        return Child(
            id: request.id,
            familyId: request.familyId,
            name: request.name,
            birthDate: request.birthDate,
            grade: request.grade,
            colorHex: request.colorHex
        )
    }

    public func deleteChild(id: String, familyId: String) async throws {
        let document = db.collection("families")
            .document(familyId)
            .collection("children")
            .document(id)
        try await document.delete()
    }
}

private extension FirestoreChildrenRemoteDataSource {
    func makePayload(from request: CreateChildRequest) -> [String: Any] {
        var data: [String: Any] = [
            "name": request.name,
            "familyId": request.familyId
        ]

        if let birthDate = request.birthDate {
            data["birthDate"] = Timestamp(date: birthDate)
        }
        if let grade = request.grade, !grade.isEmpty {
            data["grade"] = grade
        }
        if let colorHex = request.colorHex, !colorHex.isEmpty {
            data["colorHex"] = colorHex
        }

        return data
    }

    func makePayload(from request: UpdateChildRequest) -> [String: Any] {
        var data: [String: Any] = [
            "name": request.name,
            "familyId": request.familyId
        ]

        if let birthDate = request.birthDate {
            data["birthDate"] = Timestamp(date: birthDate)
        } else {
            data["birthDate"] = FieldValue.delete()
        }
        if let grade = request.grade, !grade.isEmpty {
            data["grade"] = grade
        } else {
            data["grade"] = FieldValue.delete()
        }
        if let colorHex = request.colorHex, !colorHex.isEmpty {
            data["colorHex"] = colorHex
        } else {
            data["colorHex"] = FieldValue.delete()
        }

        return data
    }
}
