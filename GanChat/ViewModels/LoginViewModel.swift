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
    private(set) var errorMessage = ""
    private(set) var isLoading = false
    
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
    
    private func message(for error: Error) -> String {
        let nsError = error as NSError
        let authErrorCode = AuthErrorCode(rawValue: nsError.code)
        
        switch authErrorCode {
        case .invalidEmail:
            return "Please enter a valid email address."
            
        case .invalidCredential,
                .wrongPassword,
                .userNotFound:
            return "The email or password is incorrect."
            
        case .userDisabled:
            return "This account has been disabled."
            
        case .networkError:
            return "Unable to connect. Check your internet connection and try again."
            
        case .tooManyRequests:
            return "Too many login attempts. Please wait and try again."
            
        case .operationNotAllowed:
            return "Email login is currently unavailable."
            
        default:
            return "Unable to log in. Please try again."
        }
    }
}
