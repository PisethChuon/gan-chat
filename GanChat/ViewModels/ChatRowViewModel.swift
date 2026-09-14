//
//  ChatRowViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 14/9/26.
//

import Foundation

struct ChatRowViewModel: Identifiable {
    let id: String
    let name: String
    let messagePreview: String
    let timestamp: String
    
    var initials: String {
        let words = name.split(separator: " ")
        
        return words
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }
}

extension ChatRowViewModel {
    static var mockChats: [ChatRowViewModel] = [
        ChatRowViewModel(
            id: "tim-cook",
            name: "Tim Cook",
            messagePreview: "Looking forward to chatting with you!",
            timestamp: "9:41 PM"
        )
    ]
}
