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
        guard password == confirmPassword else {
            errorMessage = "Password doesn't match"
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
