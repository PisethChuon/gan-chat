//
//  Conversation.swift
//  GanChat
//
//  Created by chuonpiseth on 23/9/26.
//
//  A one-to-one conversation contains exactly two Firebase UIDs

import Foundation

struct Conversation {
    let id: String
    let participantIDs: [String]
    let createdAt: Date?
    let updatedAt: Date?
    let lastMessageText: String?
    let lastMessageSenderID: String?

    nonisolated init(
        id: String,
        participantIDs: [String],
        createdAt: Date?,
        updatedAt: Date? = nil,
        lastMessageText: String? = nil,
        lastMessageSenderID: String? = nil
    ) {
        self.id = id
        self.participantIDs = participantIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessageText = lastMessageText
        self.lastMessageSenderID = lastMessageSenderID
    }
    
    func includes(userID: String) -> Bool {
        participantIDs.contains(userID)
    }
}
