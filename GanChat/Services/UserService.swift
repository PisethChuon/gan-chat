//
//  UserService.swift
//  GanChat
//
//  Created by chuonpiseth on 14/9/26.
//

import Foundation
import FirebaseFirestore

final class UserService {
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
    
}
