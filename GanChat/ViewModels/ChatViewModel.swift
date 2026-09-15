//
//  ChatViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 15/9/26.
//

import Foundation
import Observation

@MainActor
@Observable

final class ChatViewModel {
    let recipientID: String
    let recipientName: String
    
    var messageText = ""
    private(set) var messages: [ChatMessage]
    
    init(chat: ChatRowViewModel) {
        recipientID = chat.id
        recipientName = chat.name
        messages = Self.makeMockMessages(
            recipientName: chat.name
        )
    }
    
    func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedMessage.isEmpty else {
            return
        }
        
        let newMessage = ChatMessage(
            text: trimmedMessage,
            isFromCurrentUser: true
        )
        
        messages.append(newMessage)
        messageText = ""
    }
    
    private static func makeMockMessages(
        recipientName: String
    ) -> [ChatMessage]{
        [
            ChatMessage(
                text: "Hi! This is \(recipientName)",
                sentAt: Date().addingTimeInterval(-300),
                isFromCurrentUser: false
            ),
            ChatMessage(
                text: "Hey! Nice to hear from you.",
                sentAt: Date().addingTimeInterval(-240),
                isFromCurrentUser: true
            ),
            ChatMessage(
                text: "How is your day going?",
                sentAt: Date().addingTimeInterval(-180),
                isFromCurrentUser: false
            ),
            ChatMessage(
                text: "It is going well. I am working on GanChat",
                sentAt: Date().addingTimeInterval(-120),
                isFromCurrentUser: true
            ),
        ]
    }
    
    
}
