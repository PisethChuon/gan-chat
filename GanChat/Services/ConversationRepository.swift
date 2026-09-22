//
//  ConversationRepository.swift
//  GanChat
//
//  Created by chuonpiseth on 23/9/26.
//

import Foundation

protocol ConversationRepository {
    func getOrCreateConversation(
        currentUserID: String,
        recipientID: String
    ) async throws -> Conversation
}
