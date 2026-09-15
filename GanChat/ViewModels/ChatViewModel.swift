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

class ChatViewModel {
    let recipientName: String
    
    init(chat: ChatRowViewModel) {
        recipientName = chat.name
    }
    
    func sendMessage() {
        
    }
    
    func makeMockMessages(
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
