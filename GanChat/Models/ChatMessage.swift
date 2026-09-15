//
//  ChatMessage.swift
//  GanChat
//
//  Created by chuonpiseth on 15/9/26.
//

import Foundation

struct ChatMessage {
    let id: UUID
    let text: String
    let sentAt: Date
    let isFromCurrentUser: Bool
    
    init (
        id: UUID = UUID(),
        text: String,
        sentAt: Date = Date(),
        isFromCurrentUser: Bool
    ) {
        self.id = id
        self.text = text
        self.sentAt = sentAt
        self.isFromCurrentUser = isFromCurrentUser
    }
}
