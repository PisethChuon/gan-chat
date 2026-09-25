import Foundation
import FirebaseFirestore

final class FirestoreMessageRepository: MessageRepository {
    static let shared = FirestoreMessageRepository()

    private let database: Firestore

    private init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }

    func send(_ message: ChatMessage) async throws {
        let trimmedText = message.text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedText.isEmpty else {
            throw MessageRepositoryError.emptyMessage
        }

        let data: [String: Any] = [
            "senderID": message.senderID,
            "text": trimmedText,
            "createdAt": FieldValue.serverTimestamp()
        ]

        try await database
            .collection("conversations")
            .document(message.conversationID)
            .collection("messages")
            .document(message.id)
            .setData(data)
    }

    func observeMessages(
        in conversationID: String
    ) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            let listener = database
                .collection("conversations")
                .document(conversationID)
                .collection("messages")
                .order(by: "createdAt")
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }

                    guard let snapshot else {
                        continuation.finish(
                            throwing: MessageRepositoryError.invalidSnapshot
                        )
                        return
                    }

                    do {
                        let messages = try snapshot.documents.map { document in
                            try Self.makeMessage(
                                from: document,
                                conversationID: conversationID
                            )
                        }
                        .sorted(by: Self.messageComesBefore)

                        continuation.yield(messages)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    private static func makeMessage(
        from document: QueryDocumentSnapshot,
        conversationID: String
    ) throws -> ChatMessage {
        let data = document.data()

        guard let senderID = data["senderID"] as? String,
              let text = data["text"] as? String else {
            throw MessageRepositoryError.invalidMessageData
        }

        let timestamp = data["createdAt"] as? Timestamp

        return ChatMessage(
            id: document.documentID,
            conversationID: conversationID,
            senderID: senderID,
            text: text,
            createdAt: timestamp?.dateValue(),
            deliveryState: document.metadata.hasPendingWrites
                ? .sending
                : .sent
        )
    }

    private static func messageComesBefore(
        _ lhs: ChatMessage,
        _ rhs: ChatMessage
    ) -> Bool {
        switch (lhs.createdAt, rhs.createdAt) {
        case let (left?, right?) where left != right:
            return left < right
        case (nil, .some):
            return false
        case (.some, nil):
            return true
        default:
            return lhs.id < rhs.id
        }
    }
}

enum MessageRepositoryError: LocalizedError {
    case emptyMessage
    case invalidSnapshot
    case invalidMessageData

    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "A message cannot be empty."
        case .invalidSnapshot:
            return "Messages could not be loaded."
        case .invalidMessageData:
            return "A message contains invalid data."
        }
    }
}
