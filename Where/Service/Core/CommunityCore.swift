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
    /// 나와 연관된 모임 목록
    var meetings: AnyPublisher<[UInt64: Meeting], CommunityCoreError> { get }
    /// 최근 살펴본 모임 정보
    var currentMeeting: AnyPublisher<Meeting?, Never> { get }
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
    /// 모임 일정 등록
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func createSchedule(id: UInt64)
    /// 모임 일정 조회
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///
    func readSchedule(id: UInt64)
    /// 모임 일정 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func updateSchedule(id: UInt64)
    /// 모임 일정 삭제
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func deleteSchedule(id: UInt64)
    /// 모임 생성
    /// - Parameters:
    ///     - info: 생성 중인 모임의 임시 정보
    func createMeeting(info: TemporaryMeetingInfo)
    /// 모임 조회
    func readMeetings()
    /// 모임 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - title: 모임 제목
    ///     - description: 모임 설명
    ///     - image: 모임 대표 이미지
    func updateMeeting(id: UInt64, title: String?, description: String?, image: UIImage?)
    /// 모임 종료
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func endMeeting(id: UInt64)
    /// 모임 탈퇴
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func exitMeeting(id: UInt64)
    /// 모임 초대현황 조회
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func readParticipants(id: UInt64)
    /// 모임 초대
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - participantId: 초대 대상의 식별자
    func inviteParticipant(id: UInt64, participantId: UInt64)
    /// 모임 초대 수락
    /// - Parameters:
    ///     - id: 초대장 식별자
    func acceptInvitation(id: UInt64)
    /// 최근 모임 정보 조회
    func readCurrentMeeting(id: UInt64)
}

enum CommunityCoreError: Error {
    
}

final class CommunityCore {
    @Published private(set) var _friends: [UInt64: User] = [:]
    @Published private(set) var _meetings: [UInt64: Meeting] = [:]
    @Published private(set) var _currentMeeting: Meeting?
    @Published private(set) var userId: UInt64?
    
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let auth: AuthentificationCoreProtocol
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
                    self?._meetings = [:]
                    return
                }
                self?.userId = userId
                self?.readFriends()
                self?.readMeetings()
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
    
    var meetings: AnyPublisher<[UInt64: Meeting], CommunityCoreError> {
        $_meetings
            .map { $0 }
            .setFailureType(to: CommunityCoreError.self)
            .eraseToAnyPublisher()
    }
    
    var currentMeeting: AnyPublisher<Meeting?, Never> {
        $_currentMeeting
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
    
    func createSchedule(id: UInt64) {
        
    }
    
    func readSchedule(id: UInt64) {
        
    }
    
    func updateSchedule(id: UInt64) {
        
    }
    
    func deleteSchedule(id: UInt64) {
        
    }
    
    func createMeeting(info: TemporaryMeetingInfo) {
        
    }
    
    func readMeetings() {
        
    }
    
    func updateMeeting(id: UInt64, title: String?, description: String?, image: UIImage?) {
        
    }
    
    func exitMeeting(id: UInt64) {
        
    }
    
    func readParticipants(id: UInt64) {
        
    }
    
    func inviteParticipant(id: UInt64, participantId: UInt64) {
        
    }
    
    func acceptInvitation(id: UInt64) {
        
    }
    
    func readCurrentMeeting(id: UInt64) {
        _currentMeeting = _meetings[id]
    }
}
