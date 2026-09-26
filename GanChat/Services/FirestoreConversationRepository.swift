//
//  FirestoreConversationRepository.swift
//  GanChat
//
//  Created by chuonpiseth on 23/9/26.
//

import Foundation
import FirebaseFirestore
import CryptoKit

// The Big idea
// Bob want to chat with Alice
//  FirestoreConversationRepository
//      Validate Bob + Alice
//      Create a deterministic conversation ID
//      Look for that conversation in Firestore
//      Found ? return it
//      Not found –> create it –> return it


// func getOrCreateconversation
// func makeConversation
// func makeConversationID

final class FirestoreConversationRepository: ConversationRepository {
    // Singleton: shared instance
    static let shared = FirestoreConversationRepository()
    
    // Property stores firestore instance
    private let database: Firestore
    
    private init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }
    
    // Remember:
    // currentUserID: Bob
    // recipientID: Alice
    func getOrCreateConversation(
        currentUserID: String,
        recipientID: String
    ) async throws -> Conversation {
        guard !currentUserID.isEmpty,
              !recipientID.isEmpty else {
            throw ConversationRepositoryError.invalidUserID
        }
        
        guard currentUserID != recipientID else {
            throw ConversationRepositoryError.cannotChatWithSelf
        }
        
        // Sorted participantID
        let participantIDs = [
            currentUserID,
            recipientID
        ].sorted()
        
        // Generate conversation ID
        let conversationID = makeConversationID(participantIDs: participantIDs)
        
        let reference = database
            .collection("conversations")
            .document(conversationID)
        
        let snapshot = try await reference.getDocument()
        
        if snapshot.exists {
            return try makeConversation(
                from: snapshot,
                expectedParticipantIDs: participantIDs
            )
        }
        
        let conversationData: [String: Any] = [
            "participantIDs": participantIDs,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await reference.setData(conversationData)
        
        // Read it again so createAt contains the server timestamp.
        let createdSnapshot = try await reference.getDocument()
        
        return try makeConversation(
            from: createdSnapshot,
            expectedParticipantIDs: participantIDs
        )
        
    }

    func observeConversations(
        for currentUserID: String
    ) -> AsyncThrowingStream<[Conversation], Error> {
        AsyncThrowingStream { continuation in
            let listener = database
                .collection("conversations")
                .whereField(
                    "participantIDs",
                    arrayContains: currentUserID
                )
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }

                    guard let snapshot else {
                        continuation.finish(
                            throwing:
                                ConversationRepositoryError.invalidConversationData
                        )
                        return
                    }

                    do {
                        let conversations = try snapshot.documents
                            .map(Self.makeConversation)
                            .sorted {
                                let leftDate = $0.updatedAt ?? $0.createdAt
                                let rightDate = $1.updatedAt ?? $1.createdAt

                                switch (leftDate, rightDate) {
                                case let (left?, right?) where left != right:
                                    return left > right
                                case (.some, nil):
                                    return true
                                case (nil, .some):
                                    return false
                                default:
                                    return $0.id < $1.id
                                }
                            }

                        continuation.yield(conversations)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    // Helper make conversation
    private func makeConversation(
        from snapshot: DocumentSnapshot,
        expectedParticipantIDs: [String]
    ) throws -> Conversation {
        let conversation = try Self.makeConversation(from: snapshot)
        
        guard conversation.participantIDs.sorted() == expectedParticipantIDs else {
            throw ConversationRepositoryError.participantMismatch
        }

        return conversation
    }

    nonisolated private static func makeConversation(
        from snapshot: DocumentSnapshot
    ) throws -> Conversation {
        guard let data = snapshot.data(),
              let participantIDs = data["participantIDs"] as? [String],
              participantIDs.count == 2 else {
            throw ConversationRepositoryError.invalidConversationData
        }

        return Conversation(
            id: snapshot.documentID,
            participantIDs: participantIDs,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue(),
            lastMessageText: data["lastMessageText"] as? String,
            lastMessageSenderID: data["lastMessageSenderID"] as? String
        )
    }
    
    // Helper generate conversationID
    private func makeConversationID(
        participantIDs: [String]
    ) -> String {
        // Including each UID's length prevents ambiguous combinations.
        let value = participantIDs
            .map { "\($0.utf8.count):\($0)" }
            .joined()
        
        let digest = SHA256.hash(data: Data(value.utf8))
        
        return digest.map {
            String(format: "%02x", $0)
        }
        .joined()
    }
    
}

enum ConversationRepositoryError: LocalizedError {
    case invalidUserID
    case cannotChatWithSelf
    case invalidConversationData
    case participantMismatch
    
    var errorDescription: String? {
        switch self {
        case .invalidUserID:
            return "A user ID is missing."
            
        case .cannotChatWithSelf:
            return "You cannot start a conversation with yourself."
            
        case .invalidConversationData:
            return "This conversation contains invalid data."
            
        case .participantMismatch:
            return "The conversation participants do not match."
        }
        
    }
}
