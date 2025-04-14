//
//  MeetingCore.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import SwiftUI
import Combine

protocol MeetingCoreProtocol {
    /// 나와 연관된 모임 목록
    var meetingsSubject: CurrentValueSubject<[UInt64: Meeting], MeetingCoreError> { get }
    /// 최근 살펴본 모임 정보
    var currentMeetingSubject: CurrentValueSubject<Meeting?, Never> { get }
    
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

enum MeetingCoreError: Error {
    
}

final class MeetingCore {
    @Published private var _meetings = [UInt64: Meeting]()
    
    private var userID: UInt64?
    
    private let tokenStorage: TokenStorageProtocol
    private let placeCore: PlaceCoreProtocol
    private let authCore: AuthentificationCoreProtocol
    let meetingsSubject = CurrentValueSubject<[UInt64: Meeting], MeetingCoreError>([:])
    let currentMeetingSubject = CurrentValueSubject<Meeting?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authCore: AuthentificationCoreProtocol,
        placeCore: PlaceCoreProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.authCore = authCore
        self.placeCore = placeCore
        self.tokenStorage = tokenStorage
        subscribe()
    }
    
    private func subscribe() {
        authCore.userSubject
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .loginFailed, .notSupported, .socialAuthProviderAuthorizationFailed, .unknown, .userInfoFetchFailed:
                        self?._meetings = [:]
                        self?.userID = nil
                    case .logoutFailed:
                        break
                    @unknown default: break
                    }
                }
            } receiveValue: { [weak self] user in
                self?.userID = user?.id
                self?.readMeetings()
            }
            .store(in: &cancellables)
        
        meetingsSubject
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: 에러 핸들링 강화
                    break
                }
            } receiveValue: { [weak self] dict in
                self?._meetings = dict
            }
            .store(in: &cancellables)
        
        currentMeetingSubject
            .sink { [weak self] meeting in
                guard let id = meeting?.id else { return }
                self?.placeCore.readPlaces(meetingID: id)
            }
            .store(in: &cancellables)
    }
}

// MARK: - MeetingCoreProtocol Confirmation
extension MeetingCore: MeetingCoreProtocol {
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
        Task { @MainActor in
            let meeting = PreviewHelper.shared.mockMeeting
            meetingsSubject.send([meeting.id: meeting])
        }
    }
    
    func updateMeeting(id: UInt64, title: String?, description: String?, image: UIImage?) {
        
    }
    
    func endMeeting(id: UInt64) {
        
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
        currentMeetingSubject.send(_meetings[id])
    }
}
