//
//  ConversationDestinationViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 23/9/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ConversationDestinationViewModel {
    enum State {
        case loading
        case ready(Conversation)
        case failed(String)
    }
    
    private(set) var state: State = .loading
    
    let currentUserID: String
    private let recipient: User
    private let repository: any ConversationRepository
    
    @ObservationIgnored
    private var loadingTask: Task<Void, Never>?
    
    init(
        currentUserID: String,
        recipient: User,
        repository: any ConversationRepository =
        FirestoreConversationRepository.shared
    ) {
        self.currentUserID = currentUserID
        self.recipient = recipient
        self.repository = repository
    }
    
    func loadConversation() {
        guard loadingTask == nil else {
            return
        }
        
        state = .loading
        
        loadingTask = Task { [weak self] in
            guard let self else {
                return
            }
            
            do {
                let conversation =
                try await repository.getOrCreateConversation(
                    currentUserID: currentUserID,
                    recipientID: recipient.id
                )
                
                try Task.checkCancellation()
                
                state = .ready(conversation)
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                
                state = .failed(
                    error.localizedDescription
                )
            }
            
            loadingTask = nil
        }
    }
    
    func retry() {
        loadingTask?.cancel()
        loadingTask = nil
        loadConversation()
    }
    
    func cancel() {
        loadingTask?.cancel()
        loadingTask = nil
    }
}
