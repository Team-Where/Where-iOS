//
//  InviteFriendsViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/9/25.
//

import Foundation
import Combine
import Swinject

final class InviteFriendsViewModel: ObservableObject {
    @Published private(set) var friendsDataSource = [FriendCellDataSource]()
    @Published private(set) var searchedFriends = [FriendCellDataSource]()
    @Published private(set) var invitationStates = [MeetingInvitationState]()
    @Published var floaterType: FloaterType?
    @Published var isSearching: Bool = false
    @Published var searchingText: String = String()
    @Published private var _meetingID: UInt64!
    
    private var invitationStatesDict = [UInt64: MeetingInvitationState]()
    var invitedFriends: [MeetingInvitationState] { invitationStates.filter { $0.isInvited } }
    var pendingFriends: [MeetingInvitationState] { invitationStates.filter { $0.isInvited == false } }
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        $searchingText
            .removeDuplicates()
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard text.isEmpty == false,
                      let filtered = self?.friendsDataSource.filter({ $0.friend.nickname.contains(text) })
                else {
                    self?.searchedFriends.removeAll()
                    return
                }
                
                self?.searchedFriends = filtered
            }
            .store(in: cancellableBag, key: "SearchingText")
        
        communityCore.friends
            .combineLatest(
                meetingCore.relatedMeetingIDs,
                meetingCore.meetingSummaries
            )
            .map { [weak self] friends, relatedMeetings, summaries in
                guard let self else { return [] }
                
                var dataSource = [FriendCellDataSource]()
                let now = Date.now
                
                for friend in friends.values {
                    let friendID = friend.id
                    let sharedMeetingIDs = relatedMeetings[friendID] ?? []
                    let count = sharedMeetingIDs.count
                    let isInvited = self.invitationStatesDict[friendID]?.isInvited ?? false
                    let isRecent = sharedMeetingIDs.contains {
                        guard let summary = summaries[$0] else { return false }
                        return summary.finishedAt?.isRecent(compareTo: now) ?? false
                    }
                    let item = FriendCellDataSource(
                        id: friendID,
                        friend: friend,
                        meetingCount: count,
                        isInvited: isInvited,
                        isRecent: isRecent
                    )
                    dataSource.append(item)
                }
                
                dataSource.sort {
                    $0.isRecent == $1.isRecent ? $0.friend.nickname < $1.friend.nickname : $0.isRecent
                }
                
                return dataSource
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] dataSource in
                self?.friendsDataSource = dataSource
            }
            .store(in: cancellableBag, key: "Friends")
        
        meetingCore.invitationStatus
            .combineLatest($_meetingID)
            .compactMap { (dict, id) -> [MeetingInvitationState]? in
                guard let id = id else { return nil }
                return dict[id]
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] status in
                self?.invitationStatesDict = status.reduce(into: [:]) { $0[$1.guestID] = $1 }
                self?.invitationStates = status
            }
            .store(in: cancellableBag, key: "InvitationStatus")
    }
}

// MARK: - Nested Types
extension InviteFriendsViewModel {
    struct FriendCellDataSource: Identifiable {
        /// 친구 식별자
        let id: UInt64
        /// 친구 정보
        let friend: FriendRelationship
        /// 함께한 모임의 횟수
        let meetingCount: Int
        /// 해당 모임의 초대 여부
        var isInvited: Bool
        /// 최근 만난 친구 상태
        let isRecent: Bool
    }
    
    enum FloaterType: FloaterContent {
        case invited
        case errorOccured(message: String)
        
        var title: String {
            switch self {
            case .invited: return "초대되었습니다."
            case .errorOccured(let message): return message
            }
        }
    }
}

// MARK: - Interfaces
extension InviteFriendsViewModel {
    func inviteFriend(_ friend: FriendRelationship) {
        cancellableBag[#function] = meetingCore.inviteParticipant(id: _meetingID, guest: friend)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: self?.floaterType = .invited
                case .failure: self?.floaterType = .errorOccured(message: "친구 초대가 이루어지지 않았어요.")
                }
            } receiveValue: { _ in }
    }
    
    func inviteFriendWithKakao(_ completion: @escaping (URL) -> Void) {
        cancellableBag[#function] = meetingCore.inviteParticipantWithKakao(id: _meetingID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure: self?.floaterType = .errorOccured(message: "잠시 후 다시 시도해주세요.")
                }
            } receiveValue: { url in
                completion(url)
            }
    }
    
    func setMeeting(id: UInt64) {
        self._meetingID = id
    }
}
