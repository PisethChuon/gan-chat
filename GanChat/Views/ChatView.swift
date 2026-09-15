//
//  ChatView.swift
//  GanChat
//
//  Created by chuonpiseth on 16/9/26.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    
    init(chat: ChatRowViewModel) {
        _viewModel = State(
            initialValue: ChatViewModel(chat: chat)
        )
    }
    
    var body: some View {
        
    }
}

#Preview {
    NavigationStack {
        ChatView(chat: ChatRowViewModel.mockChats[0])
    }
}
