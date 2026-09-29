import Foundation

protocol MessageRepository {
    func send(
        _ message: ChatMessage,
        recipientID: String
    ) async throws

    func markConversationAsRead(
        conversationID: String,
        userID: String
    ) async throws

    func observeMessages(
        in conversationID: String
    ) -> AsyncThrowingStream<[ChatMessage], Error>
}
