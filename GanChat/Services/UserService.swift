//
//  UserService.swift
//  GanChat
//
//  Created by chuonpiseth on 14/9/26.
//

import Foundation
import FirebaseFirestore

final class UserService: UserRepository {
    static let shared = UserService()
    
    private let database: Firestore
    
    private init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }
    
    func createUserProfile(
        uid: String,
        username: String
    ) async throws {
        let normalizedUsername = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
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
    
    func searchUsers(
        username: String,
        excludingUID: String
    ) async throws -> [User] {
        let normalizedUsername = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        guard !normalizedUsername.isEmpty else {
            return []
        }
        
        let snapshot = try await database
            .collection("users")
            .whereField("normalizedUsername",
                        isEqualTo: normalizedUsername).getDocuments(source: .server)
        var users: [User] = []

        for document in snapshot.documents {
            try Task.checkCancellation()
            
            let uid = document.documentID
            
            // Do not show the signed-in user.
            guard uid != excludingUID else {
                continue
            }
            
            do {
                let user = try await fetchUserProfile(uid: uid)
                
                // The document ID is the Firebase identity.
                guard user.id == uid else {
                    throw UserServiceError.invalidProfileData
                }
                
                // The profile may have changed since the query.
                guard user.normalizedUsername == normalizedUsername else {
                    continue
                }
                
                users.append(user)
            } catch UserServiceError.profileNotFound {
                // A profile may be deleted between the tow reads.
                continue
            }
        }
        
        return users.sorted { $0.id < $1.id}
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
