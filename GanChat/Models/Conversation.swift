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
    let unreadParticipantIDs: [String]

    nonisolated init(
        id: String,
        participantIDs: [String],
        createdAt: Date?,
        updatedAt: Date? = nil,
        lastMessageText: String? = nil,
        lastMessageSenderID: String? = nil,
        unreadParticipantIDs: [String] = []
    ) {
        self.id = id
        self.participantIDs = participantIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessageText = lastMessageText
        self.lastMessageSenderID = lastMessageSenderID
        self.unreadParticipantIDs = unreadParticipantIDs
    }
    
    func includes(userID: String) -> Bool {
        participantIDs.contains(userID)
    }

    func isUnread(for userID: String) -> Bool {
        unreadParticipantIDs.contains(userID)
    }
}
