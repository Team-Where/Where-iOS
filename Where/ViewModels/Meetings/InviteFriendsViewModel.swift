//
//  InviteFriendsViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/9/25.
//

import Foundation
import Combine

final class InviteFriendsViewModel: ObservableObject {
    @Published var friends: [User] = [
        .init(nickname: "나", isFavorite: false),
        .init(nickname: "죠니월드", isFavorite: false),
        .init(nickname: "이초홍", isFavorite: false),
        .init(nickname: "두니주니", isFavorite: false),
    ]
    
    @Published var isFloaterPresented: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchingText: String = String()
    @Published var searchedFriends: [User] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
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
