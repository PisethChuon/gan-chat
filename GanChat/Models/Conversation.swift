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
    
    func includes(userID: String) -> Bool {
        participantIDs.contains(userID)
    }
}
