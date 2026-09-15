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
    
    func makeMockMessages() {
        
    }
    
}
