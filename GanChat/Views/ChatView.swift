import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel

    init(
        conversation: Conversation,
        currentUserID: String,
        recipient: User,
        repository: any MessageRepository =
            FirestoreMessageRepository.shared
    ) {
        _viewModel = State(
            initialValue: ChatViewModel(
                conversation: conversation,
                currentUserID: currentUserID,
                recipientName: recipient.username,
                repository: repository
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }

            messageList
            Divider()
            messageComposer
        }
        .navigationTitle(viewModel.recipientName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.startObserving()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var messageList: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        ContentUnavailableView(
                            "No messages yet",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Send the first message.")
                        )
                        .padding(.top, 80)
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser:
                                    message.senderID == viewModel.currentUserID
                            )
                            .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count, initial: true) {
                scrollToLatestMessage(using: scrollProxy)
            }
        }
    }

    private var messageComposer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "Message...",
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
                if viewModel.isSending {
                    ProgressView()
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                }
            }
            .disabled(!viewModel.canSendMessage)
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
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 50)
            }

            VStack(
                alignment: isFromCurrentUser ? .trailing : .leading,
                spacing: 4
            ) {
                Text(message.text)
                    .foregroundStyle(
                        isFromCurrentUser ? Color.white : Color.primary
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                            ? Color.accentColor
                            : Color.secondary.opacity(0.15)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                HStack(spacing: 4) {
                    if let createdAt = message.createdAt {
                        Text(
                            createdAt.formatted(
                                date: .omitted,
                                time: .shortened
                            )
                        )
                    }

                    if isFromCurrentUser,
                       message.deliveryState == .sending {
                        Text("Sending…")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            if !isFromCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#if DEBUG
private final class PreviewMessageRepository: MessageRepository {
    func send(_ message: ChatMessage) async throws {}

    func observeMessages(
        in conversationID: String
    ) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            continuation.yield([
                ChatMessage(
                    conversationID: conversationID,
                    senderID: "other-user",
                    text: "Hello!",
                    createdAt: Date(),
                    deliveryState: .sent
                )
            ])
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: Conversation(
                id: "preview-conversation",
                participantIDs: ["preview-user", "other-user"],
                createdAt: Date()
            ),
            currentUserID: "preview-user",
            recipient: User(
                id: "other-user",
                username: "test2",
                normalizedUsername: "test2",
                createdAt: Date()
            ),
            repository: PreviewMessageRepository()
        )
    }
}
#endif
