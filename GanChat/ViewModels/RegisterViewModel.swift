//
//  RegisterViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 8/9/26.
//

import Foundation
import Observation

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

    init(authService: FirebaseAuthService = .shared) {
        self.authService = authService
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
            try await authService.register(
                email: trimmedEmail,
                password: password
            )

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
