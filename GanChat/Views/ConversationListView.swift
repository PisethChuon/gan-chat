//
//  ConversationListView.swift
//  GanChat
//
//  Created by chuonpiseth on 9/9/26.
//

import SwiftUI

struct ConversationListView: View {
    @State private var logoutErrorMessage = ""

    private let authService = FirebaseAuthService.shared

    var body: some View {
        VStack {
            Text("Conversation list")

            if !logoutErrorMessage.isEmpty {
                Text(logoutErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Logout", role: .destructive) {
                    logout()
                }
            }
        }
    }

    private func logout() {
        logoutErrorMessage = ""

        do {
            try authService.logout()
        } catch {
            logoutErrorMessage = "Unable to log out. Please try again."
        }
    }
}

#Preview {
    NavigationStack {
        ConversationListView()
    }
}
