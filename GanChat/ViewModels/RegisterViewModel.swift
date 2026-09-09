//
//  RegisterViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 8/9/26.
//

import Foundation
import FirebaseAuth

@Observable
class RegisterViewModel {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    var errorMessage: String = ""
    var isLoading: Bool = false
        
    func register() async -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password can't be empty"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Password doesn't match"
            return false
        }
        
        isLoading = true
        
        defer { isLoading = false }
        
        errorMessage = ""
        
        do {
            let _ = try await Auth.auth().createUser(withEmail: trimmedEmail, password: password)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
