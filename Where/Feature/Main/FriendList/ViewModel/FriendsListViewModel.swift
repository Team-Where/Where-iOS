//
//  FriendsListViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import Foundation
import Combine

final class FriendsListViewModel: ObservableObject {
    @Published var sheetType: SheetType?
    @Published var route: Route?
    @Published var friends: [FriendRelationship] = []
    @Published var searchedFriends: [FriendRelationship] = []
    @Published var searchingText: String = String()
    @Published var isEditing: Bool = false
    
    var isSearching: Bool { searchingText.isEmpty == false }
    
    private let communityCore: CommunityCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(communityCore: CommunityCoreProtocol) {
        self.communityCore = communityCore
        subscribe()
    }
    
    private func subscribe() {
        communityCore.friends
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
                self?.friends = dict.values.map { $0 }.sorted { $0.nickname < $1.nickname }
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

// MARK: Nested Types
extension FriendsListViewModel {
    /// 친구목록 내에서 구분되는 섹션의 종류
    enum SectionType {
        /// 일반 친구
        case common
        /// 즐겨찾기 친구
        case favorite
        
        var title: String {
            switch self {
            case .common: "친구"
            case .favorite: "즐겨찾기"
            }
        }
    }
    
    /// 친구목록 내에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        /// 친구삭제
        case deleteFriend(friend: FriendRelationship)
        /// 나와의 모임활동 보기
        case historyWithFriend(friend: FriendRelationship)
        
        var id: String { String(describing: self) }
    }
    
    /// 친구목록 내에서 라우팅 가능한 Path의 종류
    enum Route: Identifiable, Hashable {
        /// 나와의 모임활동 상세 보기
        case historyReminder(friend: FriendRelationship)
        
        var id: String { String(describing: self) }
        
        static func == (lhs: Route, rhs: Route) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

// MARK: Interfaces
extension FriendsListViewModel {
    func toggleEditMode() {
        isEditing.toggle()
    }
    
    func deleteFriend(by id: UInt64) {
        communityCore.deleteFriend(id: id)
    }
    
    func toggleBookmark(by id: UInt64) {
        communityCore.toggleBookmarkFriend(id: id)
    }
}
