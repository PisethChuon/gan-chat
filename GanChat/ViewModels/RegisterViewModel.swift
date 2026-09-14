//
//  RegisterViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 8/9/26.
//

import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class RegisterViewModel {
    var username = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    private(set) var errorMessage = ""
    private(set) var isLoading = false

    private let authService: FirebaseAuthService
    private let userService: UserService

    init(
        authService: FirebaseAuthService = .shared,
        userService: UserService = .shared
    ) {
        self.authService = authService
        self.userService = userService
    }

    func register() async -> Bool {
        guard !isLoading else {
            return false
        }

        let trimmedUsername = username.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedUsername.isEmpty else {
            errorMessage = "Please enter a username."
            return false
        }

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter a password."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {
            let authResult = try await authService.register(
                email: trimmedEmail,
                password: password
            )
            
            do {
                try await userService.createUserProfile(
                    uid: authResult.user.uid,
                    username: trimmedUsername
                )
                
                return true
            } catch {
                try? await authResult.user.delete()
                
                errorMessage = """
                    Your account profile could not be created. Please try again.
                    """
            }

            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
