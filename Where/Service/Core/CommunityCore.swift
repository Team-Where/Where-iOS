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
    var friends: AnyPublisher<[UInt64: User], CommunityCoreError> { get }
    
    /// 사용자 식별자
    var userId: UInt64? { get }
    
    /// 친구 추가
    func createFriend(friend: User)
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
    @Published private(set) var _friends: [UInt64: User] = [:]
    @Published private(set) var userId: UInt64?
    
    private let tokenStorage: TokenStorageProtocol
    private let auth: AuthentificationCoreProtocol
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
                guard let userId = user?.id else {
                    self?.userId = nil
                    self?._friends = [:]
                    return
                }
                self?.userId = userId
                self?.readFriends()
            }
            .store(in: &cancellables)
    }
}

// MARK: CommunityCoreProtocol Confirmation
extension CommunityCore: CommunityCoreProtocol {
    var friends: AnyPublisher<[UInt64: User], CommunityCoreError> {
        $_friends
            .map { $0 }
            .setFailureType(to: CommunityCoreError.self)
            .eraseToAnyPublisher()
    }
    
    func createFriend(friend: User) {
        
    }
    
    func readFriends() {
        
    }
    
    func deleteFriend(id: UInt64) {
        
    }
    
    func toggleBookmarkFriend(id: UInt64) {
        
    }
}
