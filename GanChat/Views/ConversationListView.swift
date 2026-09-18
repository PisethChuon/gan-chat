//
//  ConversationListView.swift
//  GanChat
//
//  Created by chuonpiseth on 9/9/26.
//

import SwiftUI

struct ConversationListView: View {
    @State private var viewModel = ConversationListViewModel()

    var body: some View {
        VStack {
            UserSearchComponent()
            List {
                if !viewModel.logoutErrorMessage.isEmpty {
                    Text(viewModel.logoutErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                ForEach(viewModel.chats) { chat in
                    NavigationLink {
                        ChatView(chat: chat)
                    } label: {
                        ChatRowView(viewModel: chat)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout", role: .destructive) {
                        viewModel.logout()
                    }
                }
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        ConversationListView()
    }
}
