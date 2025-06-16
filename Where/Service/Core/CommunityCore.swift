//
//  CommunityCore.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import SwiftUI
import Combine

protocol CommunityCoreProtocol: CoreProtocol {
    /// 나의 친구 목록
    var friends: AnyPublisher<[UInt64: FriendRelationship], Never> { get }
    
    /// 특정 친구와 함께한 모임 조회
    func readHistoryWithFriend(id: UInt64)
    /// 친구 삭제
    func deleteFriend(id: UInt64) -> AnyPublisher<Void, CommunityCoreError>
    /// 친구 즐겨찾기 토글
    func toggleBookmarkFriend(id: UInt64)
}

protocol CommunityMediationProtocol {
    /// 현재 사용자의 친구 목록 로드를 지시, 중재자에 의해 호출됨
    /// - Parameters:
    ///     - 친구 목록을 로드할 사용자 식별자
    func loadFriends(userID: UInt64)
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
    /// 사용자 로그아웃 시 작업 수행을 지시, 중재자에 의해 호출됨
    func userDidLogout()
}

enum CommunityCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class CommunityCore {
    weak var mediator: Notifiable?
    
    private var _friends = [UInt64: FriendRelationship]()
    private var currentUserID: UInt64?
    
    private let friendsSubject = CurrentValueSubject<[UInt64: FriendRelationship], Never>([:])
    
    private let apiService: APIServable
    private let cancellableBag = CancellableBag()
    
    init(
        apiService: APIServable
    ) {
        self.apiService = apiService
        subscribe()
    }
    
    private func subscribe() {
        friendsSubject
            .sink { [weak self] dict in
                self?._friends = dict
            }
            .store(in: cancellableBag, key: "FriendsSubject")
    }
}

// MARK: CommunityCoreProtocol Confirmation
extension CommunityCore: CommunityCoreProtocol {
    var friends: AnyPublisher<[UInt64 : FriendRelationship], Never> {
        friendsSubject.eraseToAnyPublisher()
    }
    
    func readHistoryWithFriend(id: UInt64) {
        mediator?.notify(event: .historyWithFriendWillUpdate(friendID: id))
    }
    
    func deleteFriend(id: UInt64) -> AnyPublisher<Void, CommunityCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = DeleteFriendDTO.Request(userID: userID, friendID: id)
        
        return apiService
            .requestVoidPublisher(Endpoint.deleteFriend(dto: dto))
            .mapError { CommunityCoreError.networkingError($0) }
            .map { [weak self] _ in
                guard var friends = self?.friendsSubject.value else { return }
                friends[id] = nil
                self?.friendsSubject.send(friends)
            }
            .eraseToAnyPublisher()
    }
    
    func toggleBookmarkFriend(id: UInt64) {
        guard let userID = currentUserID else { return }
        
        let dto = BookmarkFriendDTO.Request(userID: userID, friendID: id)
        
        cancellableBag[#function] = apiService
            .requestPublisher(Endpoint.bookmarkFriend(dto: dto), BookmarkFriendDTO.Response.self)
            .sink { completion in
                
            } receiveValue: { [weak self] response in
                guard var friends = self?.friendsSubject.value,
                      let oldFriend = friends[response.friendID]
                else { return }
                
                let newFriend = FriendRelationship(
                    id: response.friendID,
                    nickname: oldFriend.nickname,
                    imageURL: oldFriend.imageURL,
                    isFavorite: response.isBookmarked
                )
                
                friends[response.friendID] = newFriend
                self?.friendsSubject.send(friends)
            }
    }
}

// MARK: - CommunityMediationProtocol Conformation
extension CommunityCore: CommunityMediationProtocol {
    func loadFriends(userID: UInt64) {
        cancellableBag[#function] = apiService
            .requestPublisher(Endpoint.readFriends(userID: userID), ReadFriendsDTO.Response.self)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] response in
                let friends: [(friend: FriendRelationship, meetingSummaries: [Meeting])] = response
                    .map { dto in
                        let meetingSummaries = dto.relatedMeetingDetails?.map { $0.asEntity() } ?? []
                        let friend = dto.asEntity()
                        return (friend, meetingSummaries)
                    }
                
                let friendsDict = friends.reduce(into: [:]) { $0[$1.friend.id] = $1.friend }
                let meetingIDsDict = friends.reduce(into: [:]) { $0[$1.friend.id] = $1.meetingSummaries.map({ $0.id }) }
                let meetingSummaryDict = Set(friends.flatMap ({ $0.meetingSummaries })).reduce(into: [:]) { $0[$1.id] = $1 }
                
                self?.friendsSubject.send(friendsDict)
                self?.mediator?.notify(event: .friendsListUpdated(meetingIDs: meetingIDsDict, summaries: meetingSummaryDict))
            }
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
    
    func userDidLogout() {
        currentUserID = nil
        friendsSubject.send([:])
    }
}
