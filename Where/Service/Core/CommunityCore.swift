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
    var friends: AnyPublisher<[UInt64: FriendRelationship], CommunityCoreError> { get }
    
    /// 친구 추가
    func createFriend(friend: FriendRelationship)
    /// 특정 친구와 함께한 모임 조회
    func readHistoryWithFriend(id: UInt64)
    /// 친구 삭제
    func deleteFriend(id: UInt64)
    /// 친구 즐겨찾기 토글
    func toggleBookmarkFriend(id: UInt64)
}

protocol CommunityMediationProtocol {
    /// 현재 사용자의 친구 목록 로드를 지시, 중재자에 의해 호출됨
    /// - Parameters:
    ///     - 친구 목록을 로드할 사용자 식별자
    func loadFriends(userID: UInt64)
}

enum CommunityCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class CommunityCore {
    weak var mediator: Notifiable?
    
    private var _friends = [UInt64: FriendRelationship]()
    
    private let friendsSubject = CurrentValueSubject<[UInt64: FriendRelationship], CommunityCoreError>([:])
    
    private let apiService: APIServable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        apiService: APIServable
    ) {
        self.apiService = apiService
        subscribe()
    }
    
    private func subscribe() {
        friendsSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] dict in
                self?._friends = dict
            }
            .store(in: &cancellables)
    }
}

// MARK: CommunityCoreProtocol Confirmation
extension CommunityCore: CommunityCoreProtocol {
    var friends: AnyPublisher<[UInt64 : FriendRelationship], CommunityCoreError> {
        friendsSubject.eraseToAnyPublisher()
    }
    
    func createFriend(friend: FriendRelationship) {
        
    }
    
    func readHistoryWithFriend(id: UInt64) {
        mediator?.notify(event: .historyWithFriendWillUpdate(friendID: id))
    }
    
    func deleteFriend(id: UInt64) {
        
    }
    
    func toggleBookmarkFriend(id: UInt64) {
        
    }
}

// MARK: - CommunityMediationProtocol Conformation
extension CommunityCore: CommunityMediationProtocol {
    func loadFriends(userID: UInt64) {
        apiService
            .requestPublisher(Endpoint.readFriends(userID: userID), ReadFriendsDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let friends: [(friend: FriendRelationship, meetingSummaries: [MeetingSummary])] = response
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
            .store(in: &cancellables)
    }
}
