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
    /// 특정 친구 조회
    func fetchFriend(id: UInt64) -> FriendRelationship?
    /// 친구 삭제
    func deleteFriend(id: UInt64)
    /// 친구 즐겨찾기 토글
    func toggleBookmarkFriend(id: UInt64)
}

protocol CommunityMediationProtocol {
    /// 현재 사용자의 친구 목록 로드를 지시, 중재자에 의해 호출됨
    /// - Parameters:
    ///     - 친구 목록을 로드할 사용자 식별자
    func loadFriends()
    
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
}

enum CommunityCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class CommunityCore {
    weak var mediator: Notifiable?
    
    private var _friends = [UInt64: FriendRelationship]()
    
    private let friendsSubject = CurrentValueSubject<[UInt64: FriendRelationship], CommunityCoreError>([:])
    
    private var currentUserID: UInt64?
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
                
                guard let userID = self?.currentUserID else { return }
                self?.mediator?.notify(event: .friendListUpdated(id: userID))
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
    
    func fetchFriend(id: UInt64) -> FriendRelationship? {
        _friends[id]
    }
    
    func deleteFriend(id: UInt64) {
        
    }
    
    func toggleBookmarkFriend(id: UInt64) {
        
    }
}

// MARK: - CommunityMediationProtocol Conformation
extension CommunityCore: CommunityMediationProtocol {
    func loadFriends() {
        // TODO: 현재 사용자 식별자를 사용하여 친구 목록 로직 구현
        // 1. 캐시 확인, 없다면 네트워크 요청
        // 2. 결과에 따라 friendsSubject로 send
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
}
