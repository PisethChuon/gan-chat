//
//  AuthSessionViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 13/9/26.
//

import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class AuthSessionViewModel {
    private(set) var currentUser: FirebaseAuth.User?
    private(set) var isCheckingSession = true

    nonisolated(unsafe) private let authService: FirebaseAuthService
    nonisolated(unsafe) private var authListenerHandle: AuthStateDidChangeListenerHandle?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    init(authService: FirebaseAuthService = .shared) {
        self.authService = authService
        observeAuthenticationState()
    }

    private func observeAuthenticationState() {
        authListenerHandle = authService.observeAuthentication {
            [weak self] user in

            Task { @MainActor in
                self?.currentUser = user
                self?.isCheckingSession = false
            }
        }
    }

    deinit {
        if let authListenerHandle {
            authService.removeAuthenticationObserver(
                authListenerHandle
            )
        }
    }
}
