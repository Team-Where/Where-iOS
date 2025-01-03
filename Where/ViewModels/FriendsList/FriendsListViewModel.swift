//
//  FriendsListViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import Foundation
import Combine

final class FriendsListViewModel: ObservableObject {
    @Published var friends: [User] = [
        .init(nickname: "Swain", isFavorite: false),
        .init(nickname: "즐겨찾기한 친구", isFavorite: true),
        .init(nickname: "삭제될 친구", isFavorite: true),
    ]
    @Published var searchedFriends: [User] = []
    @Published var searchingText: String = String()
    @Published var isEditing: Bool = false
    
    var isSearching: Bool { searchingText.isEmpty == false }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        $searchingText
            .removeDuplicates()
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
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
    
    func deleteFriend(by id: UUID) {
        guard let index = friends.firstIndex(where: { id == $0.id }) else { return }
        friends.remove(at: index)
        
        guard let index = searchedFriends.firstIndex(where: { id == $0.id }) else { return }
        searchedFriends.remove(at: index)
    }
}
