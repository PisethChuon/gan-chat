//
//  ConversationListView.swift
//  GanChat
//
//  Created by chuonpiseth on 9/9/26.
//

import SwiftUI

struct ConversationListView: View {
    let currentUserID: String

    @State private var viewModel = ConversationListViewModel()
    @State private var searchViewModel = UserSearchViewModel()
    
    private struct ConversationDestinationView: View {
        let recipient: User
        
        @State private var viewModel: ConversationDestinationViewModel
        
        init(
            currentUserID: String,
            recipient: User
        ) {
            self.recipient = recipient
            
            _viewModel = State(
                initialValue: ConversationDestinationViewModel(
                    currentUserID: currentUserID,
                    recipient: recipient
                )
            )
        }
        
        var body: some View {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Opening conversation...")
                case .ready(let conversation):
                    ChatView(
                        conversation: conversation,
                        currentUserID: viewModel.currentUserID,
                        recipient: recipient
                    )
                    
                case .failed(let message):
                    ContentUnavailableView {
                        Label(
                            "Unable to Open Conversation",
                            systemImage: "exclamationmark.triangle"
                        )
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") {
                            viewModel.retry()
                        }
                    }
                }
            }
            .navigationTitle(recipient.username)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadConversation()
            }
            .onDisappear {
                viewModel.cancel()
            }
        }
    }
    
    var body: some View {
        VStack {
            UserSearchComponent(
                searchText: $searchViewModel.searchText,
                onSearch: search
            )
            
            List {
                if !viewModel.logoutErrorMessage.isEmpty {
                    Text(viewModel.logoutErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                
                if searchViewModel.hasSearchText {
                    searchContent
                } else {
                    conversationContent
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout", role: .destructive) {
                        searchViewModel.resetSearch()
                        viewModel.logout()
                    }
                }
            }
        }
        .task {
            viewModel.startObserving(currentUserID: currentUserID)
        }
        .onDisappear {
            searchViewModel.resetSearch()
            viewModel.stopObserving()
        }
    }

    @ViewBuilder
    private var conversationContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading conversations…")

        case .loaded:
            if viewModel.items.isEmpty {
                ContentUnavailableView(
                    "No conversations yet",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text(
                        "Search for a username to start chatting."
                    )
                )
            } else {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        ChatView(
                            conversation: item.conversation,
                            currentUserID: currentUserID,
                            recipient: item.recipient
                        )
                    } label: {
                        ChatRowView(viewModel: item.rowViewModel)
                    }
                }
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .foregroundStyle(.red)

                Button("Retry") {
                    viewModel.retry(currentUserID: currentUserID)
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchContent: some View {
        switch searchViewModel.state {
        case .idle:
            Text("Enter a complete username and press Search.")
                .foregroundStyle(.secondary)
            
        case .loading:
            ProgressView("Searching…")
            
        case .results(let users):
            if users.isEmpty {
                Text("No other users found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(users) { user in
                    NavigationLink {
                        ConversationDestinationView(
                            currentUserID: currentUserID,
                            recipient: user
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username)
                            
                            // Distinguish accounts with the same username.
                            if users.count > 1 {
                                Text("ID: \(user.id)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .foregroundStyle(.red)
                
                Button("Retry", action: search)
            }
        }
    }
    
    private func search() {
        searchViewModel.search(currentUserID: currentUserID)
    }
}

#Preview {
    NavigationStack {
        ConversationListView(currentUserID: "preview-user")
    }
}
