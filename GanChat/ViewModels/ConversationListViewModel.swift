import Foundation
import Observation

@MainActor
@Observable
final class ConversationListViewModel {
    struct Item: Identifiable {
        let conversation: Conversation
        let recipient: User
        let currentUserID: String

        var id: String {
            conversation.id
        }

        var rowViewModel: ChatRowViewModel {
            let preview: String

            if let text = conversation.lastMessageText {
                preview = conversation.lastMessageSenderID == currentUserID
                    ? "You: \(text)"
                    : text
            } else {
                preview = "No messages yet"
            }

            return ChatRowViewModel(
                id: conversation.id,
                name: recipient.username,
                messagePreview: preview,
                timestamp: Self.formatTimestamp(
                    conversation.updatedAt ?? conversation.createdAt
                )
            )
        }

        private static func formatTimestamp(_ date: Date?) -> String {
            guard let date else {
                return ""
            }

            if Calendar.current.isDateInToday(date) {
                return date.formatted(
                    date: .omitted,
                    time: .shortened
                )
            }

            return date.formatted(
                .dateTime.month(.abbreviated).day()
            )
        }
    }

    enum State {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var items: [Item] = []
    private(set) var state: State = .idle
    private(set) var logoutErrorMessage = ""

    private let authService: FirebaseAuthService
    private let conversationRepository: any ConversationRepository
    private let userRepository: any UserRepository

    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    @ObservationIgnored
    private var profileCache: [String: User] = [:]

    init(
        authService: FirebaseAuthService = .shared,
        conversationRepository: any ConversationRepository =
            FirestoreConversationRepository.shared,
        userRepository: any UserRepository = UserService.shared
    ) {
        self.authService = authService
        self.conversationRepository = conversationRepository
        self.userRepository = userRepository
    }

    func startObserving(currentUserID: String) {
        guard observationTask == nil else {
            return
        }

        if items.isEmpty {
            state = .loading
        }

        let conversationRepository = conversationRepository

        observationTask = Task { [weak self] in
            do {
                let stream = conversationRepository.observeConversations(
                    for: currentUserID
                )

                for try await conversations in stream {
                    try Task.checkCancellation()

                    guard let self else {
                        return
                    }

                    self.items = await self.makeItems(
                        conversations: conversations,
                        currentUserID: currentUserID
                    )
                    self.state = .loaded
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                self?.state = .failed(
                    "Unable to load conversations. Please try again."
                )
            }
        }
    }

    func retry(currentUserID: String) {
        stopObserving()
        startObserving(currentUserID: currentUserID)
    }

    func stopObserving() {
        observationTask?.cancel()
        observationTask = nil
    }

    func logout() {
        logoutErrorMessage = ""
        stopObserving()

        do {
            try authService.logout()
        } catch {
            logoutErrorMessage = "Unable to log out. Please try again."
        }
    }

    private func makeItems(
        conversations: [Conversation],
        currentUserID: String
    ) async -> [Item] {
        var result: [Item] = []

        for conversation in conversations {
            guard conversation.includes(userID: currentUserID),
                  let recipientID = conversation.participantIDs.first(
                    where: { $0 != currentUserID }
                  ) else {
                continue
            }

            do {
                let recipient: User

                if let cachedUser = profileCache[recipientID] {
                    recipient = cachedUser
                } else {
                    recipient = try await userRepository.fetchUserProfile(
                        uid: recipientID
                    )
                    profileCache[recipientID] = recipient
                }

                result.append(
                    Item(
                        conversation: conversation,
                        recipient: recipient,
                        currentUserID: currentUserID
                    )
                )
            } catch {
                continue
            }
        }

        return result
    }
}
