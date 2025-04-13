//
//  InviteFriendsViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/9/25.
//

import Foundation
import Combine

final class InviteFriendsViewModel: ObservableObject {
    @Published var friends = [User]()
    @Published var searchedFriends = [User]()
    @Published var isFloaterPresented: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchingText: String = String()
    
    private let communityCore: CommunityCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(communityCore: CommunityCoreProtocol) {
        self.communityCore = communityCore
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
        
        communityCore.friendsSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print("Error: \(error)")
                    #endif
                }
            } receiveValue: { [weak self] dict in
                self?.friends = dict.values.sorted { $0.nickname < $1.nickname }
            }
            .store(in: &cancellables)
    }
}
