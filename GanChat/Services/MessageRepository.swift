import Foundation

protocol MessageRepository {
    func send(_ message: ChatMessage) async throws

    func observeMessages(
        in conversationID: String
    ) -> AsyncThrowingStream<[ChatMessage], Error>
}
