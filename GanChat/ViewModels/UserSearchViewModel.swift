//
//  UserSearchViewModel.swift
//  GanChat
//
//  Created by chuonpiseth on 21/9/26.
//

import Foundation
import Observation

@MainActor
@Observable

final class UserSearchViewModel {
    enum State {
        case idle
        case loading
        case results([User])
        case failed(String)
    }
    
    // Stores what user type
    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            resetSearch()
        }
    }

    // Tells the UI what is happenning with the search
    private(set) var state: State = .idle
    private let repository: any UserRepository
    
    // Keep a reference to the currently running search
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?
    
    // Protects old searche returnning late
    @ObservationIgnored
    private var requestID = UUID()
    
    var hasSearchText: Bool {
        !searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
    
    init(repository: any UserRepository = UserService.shared) {
        self.repository = repository
    }
    
    func search(currentUserID: String) {
        resetSearch()
        
        guard hasSearchText else { return }
        
        guard !currentUserID.isEmpty else {
            state = .failed("Please sign in before searching.")
            return
        }
        
        let query = searchText
        let activeRequestID = requestID
        let repository = repository
        
        searchTask = Task { [weak self] in
            do {
                let users = try await repository.searchUsers(
                    username: query,
                    excludingUID: currentUserID
                )
                
                try Task.checkCancellation()
                
                guard let self,
                        self.requestID == activeRequestID else {
                    return
                }
                
                self.state = .results(users)
            } catch {
                guard !Task.isCancelled,
                      let self,
                      self.requestID == activeRequestID else {
                    return
                }
                
                self.state = .failed(
                    "Unable to search users. Please try again."
                )
            }
        }
        
    }
    
    // Clean or reset search fields
    func resetSearch() {
        searchTask?.cancel()
        searchTask = nil
        requestID = UUID()
        state = .idle
    }
    
}
