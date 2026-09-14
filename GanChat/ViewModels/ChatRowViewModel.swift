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
        ),
        ChatRowViewModel(
            id: "sundar-pichai",
            name: "Sundar Pichai",
            messagePreview: "Let me know when you are available.",
            timestamp: "8:30 AM"
        ),
        ChatRowViewModel(
            id: "satya-nadella",
            name: "Satya Nadella",
            messagePreview: "That sounds like a great idea.",
            timestamp: "Yesterday"
        ),
        ChatRowViewModel(
            id: "mark-zuckerberg",
            name: "Mark Zuckerberg",
            messagePreview: "Can we talk about it tomorrow?",
            timestamp: "Yesterday"
        ),
        ChatRowViewModel(
            id: "sam-altman",
            name: "Sam Altman",
            messagePreview: "Thanks for sending that over.",
            timestamp: "Sunday"
        ),
        ChatRowViewModel(
            id: "jensen-huang",
            name: "Jensen Huang",
            messagePreview: "The new update looks really good.",
            timestamp: "Saturday"
        ),
        ChatRowViewModel(
            id: "susan-wojcicki",
            name: "Susan Wojcicki",
            messagePreview: "See you at the meeting!",
            timestamp: "Friday"
        )
    ]
}
