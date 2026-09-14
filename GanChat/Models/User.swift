//
//  User.swift
//  GanChat
//
//  Created by chuonpiseth on 8/9/26.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let username: String
    let normalizedUsername: String
    let email: String
    let createdAt: Date
}
