@preconcurrency import FirebaseFirestore
import Shared

public final class FirestoreFamiliesRemoteDataSource: FamiliesRemoteDataSourceProtocol, @unchecked Sendable {
    private let db: Firestore

    public init(database: Firestore = .firestore()) {
        db = database
    }

    public func createFamily(name: String, ownerId: String) async throws -> Family {
        let collection = db.collection("families")
        let id = collection.document().documentID
        let createdAt = Timestamp(date: Date())
        let data: [String: Any] = [
            "name": name,
            "ownerId": ownerId,
            "createdAt": createdAt,
            "memberIds": [ownerId]
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            collection.document(id).setData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        return Family(id: id, name: name, ownerId: ownerId, createdAt: createdAt.dateValue())
    }

    public func fetchFamilies(for userId: String) async throws -> [Family] {
        let snapshot: QuerySnapshot = try await withCheckedThrowingContinuation {
            (
                continuation: CheckedContinuation<QuerySnapshot, Error>
            ) in
            db.collection("families")
                .whereField("memberIds", arrayContains: userId)
                .getDocuments { snapshot, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let snapshot {
                        continuation.resume(returning: snapshot)
                    } else {
                        continuation.resume(throwing: FamilyError.unknown)
                    }
                }
        }

        return snapshot.documents.compactMap(Self.decodeFamily)
    }

    public func addFamily(_ family: Family, for userId: String) async throws {
        let ref = db.collection("families").document(family.id)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.updateData(["memberIds": FieldValue.arrayUnion([userId])]) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

private extension FirestoreFamiliesRemoteDataSource {
    static func decodeFamily(_ document: DocumentSnapshot) -> Family? {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let ownerId = data["ownerId"] as? String
        else { return nil }

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

        return Family(
            id: document.documentID,
            name: name,
            ownerId: ownerId,
            createdAt: createdAt
        )
    }
}

private enum FamilyError: Error {
    case unknown
}
