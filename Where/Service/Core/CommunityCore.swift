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
    var friendsSubject: CurrentValueSubject<[UInt64: User], CommunityCoreError> { get }
    
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
    
    private var userID: UInt64?
    
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let auth: AuthentificationCoreProtocol
    let friendsSubject = CurrentValueSubject<[UInt64: User], CommunityCoreError>([:])
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        auth: AuthentificationCoreProtocol
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
        self.auth = auth
        subscribe()
    }
    
    private func subscribe() {
        auth.userSubject
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
    func createFriend(friend: User) {
        
    }
    
    func readFriends() {
        
    }
    
    func deleteFriend(id: UInt64) {
        
    }
    
    func toggleBookmarkFriend(id: UInt64) {
        
    }
}
