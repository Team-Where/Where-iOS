//
//  FriendsListViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import Foundation
import Combine

final class FriendsListViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var searchedFriends: [User] = []
    @Published var searchingText: String = String()
    @Published var isEditing: Bool = false
    
    var isSearching: Bool { searchingText.isEmpty == false }
    
    private let community: CommunityCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(community: CommunityCoreProtocol) {
        self.community = community
        subscribe()
    }
    
    private func subscribe() {
        community.friends
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] dict in
                self?.friends = dict.values.map { $0 }
            }
            .store(in: &cancellables)
        
        $searchingText
            .removeDuplicates()
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard text.isEmpty == false,
                      let filtered = self?.friends.filter({ $0.nickname.contains(text) })
                else {
                    self?.searchedFriends.removeAll()
                    return
                }
                
                self?.searchedFriends = filtered
            }
            .store(in: &cancellables)
    }
}

// MARK: Interfaces
extension FriendsListViewModel {
    func toggleEditMode() {
        isEditing.toggle()
    }
    
    func deleteFriend(by id: UInt64) {
        community.deleteFriend(id: id)
    }
}
