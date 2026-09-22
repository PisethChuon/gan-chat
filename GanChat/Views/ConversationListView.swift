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
                    ForEach(viewModel.chats) { chat in
                        NavigationLink {
                            ChatView(chat: chat)
                        } label: {
                            ChatRowView(viewModel: chat)
                        }
                    }
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
        .onDisappear {
            searchViewModel.resetSearch()
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
                        SelectedRecipientView(user: user)
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

private struct SelectedRecipientView: View {
    let user: User

    var body: some View {
        ContentUnavailableView(
            "No messages yet",
            systemImage: "bubble.left.and.bubble.right",
            description: Text("Messaging will be available soon.")
        )
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ConversationListView(currentUserID: "preview-user")
    }
}
