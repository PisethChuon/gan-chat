//
//  FirebaseAuthService.swift
//  GanChat
//
//  Created by chuonpiseth on 8/9/26.
//
import Foundation
import FirebaseAuth

final class FirebaseAuthService {
    
    //  Singleton
    static let shared = FirebaseAuthService()
    //  Prevent everyone else use from creating another instance
    private init() {}
    
    @discardableResult
    func register(
        email: String,
        password: String,
    ) async throws -> AuthDataResult {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    @discardableResult
    func login(
        email: String,
        password: String
    ) async throws -> AuthDataResult {
        try await Auth.auth().signIn(withEmail: email, link: password)
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func observeAuthentication(
        onChange: @escaping (FirebaseAuth.User?) -> Void
    ) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            onChange(user)
        }
    }
    
    
}
