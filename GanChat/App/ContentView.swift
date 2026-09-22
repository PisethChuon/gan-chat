//
//  ContentView.swift
//  GanChat
//
//  Created by chuonpiseth on 6/9/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var sessionViewModel = AuthSessionViewModel()
    
    var body: some View {
        Group {
            if sessionViewModel.isCheckingSession {
                ProgressView("Checking session...")
            } else if let currentUser = sessionViewModel.currentUser {
                NavigationStack {
                    ConversationListView(currentUserID: currentUser.uid)
                }
                .id(currentUser.uid)
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}
