//
//  CommunityCore.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import SwiftUI
import Combine

protocol CommunityCoreProtocol {
    /// 나의 친구 목록
    var friends: AnyPublisher<[UInt64: FriendRelationship], CommunityCoreError> { get }
    
    /// 친구 추가
    func createFriend(friend: FriendRelationship)
    /// 친구 목록 조회
    func readFriends()
    /// 친구 삭제
    /// - Parameters:
    ///     - id: 삭제할 대상의 고유 식별자
    func deleteFriend(id: UInt64)
    /// 친구 즐겨찾기 토글
    /// - Parameters:
    ///     - id: 즐겨찾기 설정 또는 해제할 대상의 고유 식별자
    func toggleBookmarkFriend(id: UInt64)
}

enum CommunityCoreError: Error {
    
}

final class CommunityCore {
    @Published private(set) var _friends: [UInt64: FriendRelationship] = [:]
    
    private var userID: UInt64?
    
    private let tokenStorage: TokenStorageProtocol
    private let auth: AuthentificationCoreProtocol
    private let friendsSubject = CurrentValueSubject<[UInt64: FriendRelationship], CommunityCoreError>([:])
    private var cancellables = Set<AnyCancellable>()
    
    init(
        tokenStorage: TokenStorageProtocol,
        auth: AuthentificationCoreProtocol
    ) {
        self.tokenStorage = tokenStorage
        self.auth = auth
        subscribe()
    }
    
    private func subscribe() {
        auth.user
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] user in
                self?.userID = user?.id
                self?.readFriends()
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
    
    func readFriends() {
        Task { @MainActor in
            _friends = PreviewHelper.shared.mockFriends.reduce(into: [:]) { $0[$1.id] = $1 }
            friendsSubject.send(_friends)
        }
    }
    
    func deleteFriend(id: UInt64) {
        
    }
    
    func toggleBookmarkFriend(id: UInt64) {
        
    }
}
