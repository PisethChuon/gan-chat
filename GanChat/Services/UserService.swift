//
//  UserService.swift
//  GanChat
//
//  Created by chuonpiseth on 14/9/26.
//

import Foundation
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    
    private let database: Firestore
    
    private init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }
    
    func createUserProfile(
        uid: String,
        username: String
    ) async throws {
        let normalizedUsername = username.lowercased()
        
        let profileData: [String: Any] = [
            "uid": uid,
            "username": username,
            "normalizedUsername": normalizedUsername,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await database
            .collection("users")
            .document(uid)
            .setData(profileData)
    }
    
    func fetchUserProfile(uid: String) async throws -> User {
        let snapshot = try await database
            .collection("users")
            .document(uid)
            .getDocument()
        
        guard let data = snapshot.data() else {
            throw UserServiceError.profileNotFound
        }
        
        guard
            let storedUID = data["uid"] as? String,
            let username = data["username"] as? String,
            let normalizedUsername = data["normalizedUsername"] as? String
        else {
            throw UserServiceError.invalidProfileData
        }
        
        let timestamp = data["createdAt"] as? Timestamp
        
        
        return User(
            id: storedUID,
            username: username,
            normalizedUsername: normalizedUsername,
            createdAt: timestamp?.dateValue()
        )
    }
}

enum UserServiceError: LocalizedError {
    case profileNotFound
    case invalidProfileData
    
    var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "Ther user profile could not be found."
        case .invalidProfileData:
            return "The user profile contanis invalid data"
        }
    }
}
