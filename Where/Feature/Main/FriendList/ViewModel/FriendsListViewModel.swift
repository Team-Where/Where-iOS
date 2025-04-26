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
    @Published var route: Route?
    @Published var user: User?
    @Published var friends: [FriendRelationship] = []
    @Published var searchedFriends: [FriendRelationship] = []
    @Published var searchingText: String = String()
    @Published var isEditing: Bool = false
    @Published var meetingsCount: Int = .zero
    
    var isSearching: Bool { searchingText.isEmpty == false }
    
    private let authCore: AuthentificationCoreProtocol
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: 에러 핸들링
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
        
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
        
        meetingCore.meetingSummaries
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] dict in
                self?.meetingsCount = dict.count
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
        case historyWithFriend(user: User, friend: FriendRelationship)
        
        var id: String { String(describing: self) }
    }
    
    /// 친구목록 내에서 라우팅 가능한 Path의 종류
    enum Route: Identifiable, Hashable {
        /// 나와의 모임활동 상세 보기
        case historyReminder(user: User, friend: FriendRelationship)
        
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
        communityCore.deleteFriend(id: id)
    }
    
    func presentHistoryWithFriend(friend: FriendRelationship) {
        guard let user else { return }
        sheetType = .historyWithFriend(user: user, friend: friend)
        communityCore.readHistoryWithFriend(id: friend.id)
    }
    
    func presentHistoryReminder(friend: FriendRelationship) {
        // TODO: 추후 리팩토링 고려
        // 현재로서는 비로그인 상태에서 절대 동작할 수 없는 로직이기에 단순 return
        // 추후 토큰 만료 등으로 인해 재로그인이 필요한 상황에서 동작할 수 없도록
        // 얼럿을 띄운다던가 하는 식으로 개선할 수 있을 것 같음.
        guard let user else { return }
        dismissSheet()
        route = .historyReminder(user: user, friend: friend)
    }
    
    func toggleFavorite(by id: UInt64) {
        communityCore.toggleBookmarkFriend(id: id)
    }
}
