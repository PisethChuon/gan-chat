import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    let conversationID: String
    let currentUserID: String
    let recipientName: String

    var messageText = ""
    private(set) var messages: [ChatMessage] = []
    private(set) var errorMessage = ""
    private(set) var isSending = false

    private let repository: any MessageRepository

    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    @ObservationIgnored
    private var sendTask: Task<Void, Never>?

    var canSendMessage: Bool {
        !isSending &&
        !messageText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    init(
        conversation: Conversation,
        currentUserID: String,
        recipientName: String,
        repository: any MessageRepository =
            FirestoreMessageRepository.shared
    ) {
        conversationID = conversation.id
        self.currentUserID = currentUserID
        self.recipientName = recipientName
        self.repository = repository
    }

    func startObserving() {
        guard observationTask == nil else {
            return
        }

        errorMessage = ""
        let repository = repository
        let conversationID = conversationID

        observationTask = Task { [weak self] in
            do {
                let stream = repository.observeMessages(
                    in: conversationID
                )

                for try await messages in stream {
                    try Task.checkCancellation()
                    self?.messages = messages
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                self?.errorMessage =
                    "Unable to load messages. Please try again."
            }
        }
    }

    func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedMessage.isEmpty,
              sendTask == nil else {
            return
        }

        let message = ChatMessage(
            conversationID: conversationID,
            senderID: currentUserID,
            text: trimmedMessage
        )

        messageText = ""
        errorMessage = ""
        isSending = true

        let repository = repository

        sendTask = Task { [weak self] in
            do {
                try await repository.send(message)
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                self?.errorMessage =
                    "Unable to send the message. Please try again."

                if self?.messageText.isEmpty == true {
                    self?.messageText = trimmedMessage
                }
            }

            self?.isSending = false
            self?.sendTask = nil
        }
    }

    func stop() {
        observationTask?.cancel()
        observationTask = nil
        sendTask?.cancel()
        sendTask = nil
        isSending = false
    }
}
