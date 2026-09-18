//
//  UserSearchView.swift
//  GanChat
//
//  Created by chuonpiseth on 18/9/26.
//

import SwiftUI

struct UserSearchComponent: View {
    @State private var searchText = ""
    @FocusState private var isFocused: Bool

    // Center the content only when the user is not using the field
    private var showCentered: Bool {
        searchText.isEmpty && !isFocused
    }

    var body: some View {
        ZStack {
            // Real field: icon on the left, text on the right
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search users", text: $searchText)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.primary)
            }
            .opacity(showCentered ? 0 : 1)

            // Centered placeholder (only for the idle state)
            if showCentered {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                    Text("Search users")
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .contentShape(Capsule())
        .onTapGesture { isFocused = true }
        .glassEffect(.regular.interactive(), in: .capsule)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: showCentered)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.purple],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()

        UserSearchComponent()
    }
}
