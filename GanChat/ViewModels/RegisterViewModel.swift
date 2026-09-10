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
    // Keep the created account so a profile failure can be retried safely.
    private var pendingProfileUser: FirebaseAuth.User?
    var hasPendingProfile: Bool { pendingProfileUser != nil }
        
    func register() async -> Bool {
        guard !isLoading else { return false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username can't be empty"
            return false
        }
    
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
        
        if pendingProfileUser == nil {
            do {
                let result = try await Auth.auth().createUser(
                    withEmail: trimmedEmail,
                    password: password
                )
                pendingProfileUser = result.user
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
        }

        guard let user = pendingProfileUser else { return false }

        do {
            let profileChange = user.createProfileChangeRequest()
            profileChange.displayName = trimmedUsername
            try await profileChange.commitChanges()
        } catch {
            errorMessage = "Your account was created, but the username couldn't be saved. Tap Retry saving username. \(error.localizedDescription)"
            return false
        }

        pendingProfileUser = nil

        #if DEBUG
        // Verification is separate: a reload failure doesn't undo registration.
        do {
            try await user.reload()
            print("Firebase UID:", user.uid)
            print("Saved username:", user.displayName ?? "(missing)")
        } catch {
            print("Could not verify profile:", error.localizedDescription)
        }
        #endif

        return true
    }
}
