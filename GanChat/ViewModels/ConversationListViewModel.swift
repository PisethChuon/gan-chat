//
//  ConversationListViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 15/9/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ConversationListViewModel {
    private(set) var chats: [ChatRowViewModel]
    private(set) var logoutErrorMessage = ""

    private let authService: FirebaseAuthService

    init(
        chats: [ChatRowViewModel] = ChatRowViewModel.mockChats,
        authService: FirebaseAuthService = .shared
    ) {
        self.chats = chats
        self.authService = authService
    }

    func logout() {
        logoutErrorMessage = ""

        do {
            try authService.logout()
        } catch {
            logoutErrorMessage = "Unable to log out. Please try again."
        }
    }
}
