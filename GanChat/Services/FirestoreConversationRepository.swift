//
//  FirestoreConversationRepository.swift
//  GanChat
//
//  Created by chuonpiseth on 23/9/26.
//

import Foundation
import FirebaseFirestore

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
            throw ConversationRepositoryError.invalidUserID
        }
        
        // Sorted participantID
        let participantIDs = [
            currentUserID,
            recipientID
        ].sorted()
    }
}

enum ConversationRepositoryError: LocalizedError {
    case invalidUserID
    case cannotChatWithSelf
    
    var errorDescription: String? {
        switch self {
        case .invalidUserID:
            return "A user ID is missing."
            
        case .cannotChatWithSelf:
            return "You cannot start a conversation with yourself."
        }
    }
}
