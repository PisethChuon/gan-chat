//
//  ContentView.swift
//  GanChat
//
//  Created by chuonpiseth on 6/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var sessionViewModel = AuthSessionViewModel()
    
    var body: some View {
        Group {
            if sessionViewModel.isCheckingSession {
                ProgressView("Checking session...")
            } else if sessionViewModel.isAuthenticated {
                NavigationStack {
                    ConversationListView()
                }
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
