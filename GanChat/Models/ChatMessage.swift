//
//  ChatMessage.swift
//  GanChat
//
//  Created by chuonpiseth on 15/9/26.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    enum DeliveryState: Equatable {
        case sending
        case sent
    }

    let id: String
    let conversationID: String
    let senderID: String
    let text: String
    let createdAt: Date?
    let deliveryState: DeliveryState

    init(
        id: String = UUID().uuidString,
        conversationID: String,
        senderID: String,
        text: String,
        createdAt: Date? = nil,
        deliveryState: DeliveryState = .sending
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.createdAt = createdAt
        self.deliveryState = deliveryState
    }
}
