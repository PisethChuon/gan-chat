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
        messageList
        
        Divider()
        
        messageComposer
    }
    
    private var messageList: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                scrollToLatestMessage(using: scrollProxy)
            }
            .onChange(of: viewModel.messages.count) {
                scrollToLatestMessage(using: scrollProxy)
            }
        }
    }
    
    private var messageComposer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message...",
                      text: $viewModel.messageText,
                      axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(1...5)
            .submitLabel(.send)
            .onSubmit {
                viewModel.sendMessage()
            }
            
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
            }
//            .disabled(viewModel.canSendMessage)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
    
    private func scrollToLatestMessage(
        using scrollProxy: ScrollViewProxy
    ) {
        guard let latestMessage = viewModel.messages.last else {
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                scrollProxy.scrollTo(
                    latestMessage.id,
                    anchor: .bottom
                )
            }
        }
    }
}


private struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .foregroundStyle(message.isFromCurrentUser ? Color.white : Color.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromCurrentUser ? Color.accentColor : Color.secondary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                Text(message.sentAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if !message.isFromCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(chat: ChatRowViewModel.mockChats[0])
    }
}
