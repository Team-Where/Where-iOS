//
//  FriendsListViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import Foundation
import Combine
import Swinject

final class FriendsListViewModel: ObservableObject {
    @Published var sheetType: SheetType?
    @Published var user: User?
    @Published var friends: [FriendRelationship] = []
    @Published var searchedFriends: [FriendRelationship] = []
    @Published var searchingText: String = String()
    @Published var isEditing: Bool = false
    @Published var meetingsCount: Int = .zero
    @Published private(set) var isDeletionProcessing: Bool = false
    
    var isSearching: Bool { searchingText.isEmpty == false }
    
    private let authCore: AuthentificationCoreProtocol
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: cancellableBag, key: "CurrentUser")
        
        communityCore.friends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.friends = dict.values.sorted { $0.nickname < $1.nickname }
            }
            .store(in: cancellableBag, key: "Friends")
        
        meetingCore.meetingSummaries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.meetingsCount = dict.count
            }
            .store(in: cancellableBag, key: "MeetingSummaries")
        
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
            .store(in: cancellableBag, key: "SearchingText")
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
        case historyWithFriend(user: User, friend: FriendRelationship)
        
        var id: String { String(describing: self) }
    }
}

// MARK: Interfaces
extension FriendsListViewModel {
    func dismissSheet() {
        sheetType = nil
    }
    
    func toggleEditMode() {
        isEditing.toggle()
    }
    
    func presentDeleteFriendSheet(for friend: FriendRelationship) {
        sheetType = .deleteFriend(friend: friend)
    }
    
    func deleteFriend(by id: UInt64) {
        isDeletionProcessing = true
        
        cancellableBag[#function] = communityCore.deleteFriend(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isDeletionProcessing = false
            } receiveValue: { _ in }
    }
    
    func presentHistoryWithFriend(friend: FriendRelationship) {
        guard let user else { return }
        sheetType = .historyWithFriend(user: user, friend: friend)
        communityCore.readHistoryWithFriend(id: friend.id)
    }
    
    func toggleFavorite(by id: UInt64) {
        communityCore.toggleBookmarkFriend(id: id)
    }
}
