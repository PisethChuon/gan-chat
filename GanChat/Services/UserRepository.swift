//
//  UserRepository.swift
//  GanChat
//
//  Created by chuonpiseth on 21/9/26.
//

import Foundation

protocol UserRepository {
    func fetchUserProfile(uid: String) async throws -> User
    
    func searchUsers (
        username: String,
        excludingUID: String
    ) async throws -> [User]
}
