//
//  LoginViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 8/9/26.
//

import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class LoginViewModel {
    private let authService: FirebaseAuthService
    private var errorMessage = ""
    private var isLoading = false
    
    init(authService: FirebaseAuthService = .shared) {
        self.authService = authService
    }
    
    var email: String = ""
    var password: String = ""
    
    func login() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter you email"
            return
        }
        
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedPassword.isEmpty else {
            errorMessage = "Please enter you password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        defer {
            isLoading = false
        }
        
        do {
            try await authService.login(
                email: trimmedEmail,
                password: trimmedPassword
            )
        } catch {
            return
        }
    }
}
