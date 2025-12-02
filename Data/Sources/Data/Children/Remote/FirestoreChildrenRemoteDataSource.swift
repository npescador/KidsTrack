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
}
