//
//  MeetingCore.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import SwiftUI
import Combine

protocol MeetingCoreProtocol: CoreProtocol {
    /// 나와 연관된 모임 목록
    var meetings: AnyPublisher<[UInt64: Meeting], MeetingCoreError> { get }
    /// 친구와 함께한 모임 목록
    var meetingSummaries: AnyPublisher<[UInt64: MeetingSummary], MeetingCoreError> { get }
    
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
    /// 특정 모임 조회
    func fetchMeeting(id: UInt64) -> Meeting?
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
    /// 모임 초대
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - participantId: 초대 대상의 식별자
    func inviteParticipant(id: UInt64, participantId: UInt64)
    /// 모임 초대 수락
    /// - Parameters:
    ///     - id: 초대장 식별자
    func acceptInvitation(id: UInt64)
}

protocol MeetingMediationProtocol {
    /// 친구와 함께한 모임 목록 갱신을 지시, 중재자에 의해 호출됨
    func updateRelatedMeetings(meetingIDs: [UInt64: [UInt64]], summaries: [UInt64: MeetingSummary])
    /// 특정 친구와 함께한 모임 목록 로드를 지시, 중재자에 의해 호출됨
    func loadCurrentMeetingsWithFriend(friendID: UInt64)
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
}

enum MeetingCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class MeetingCore {
    weak var mediator: Notifiable?
    
    private var _meetings = [UInt64: Meeting]()
    private var _summaries = [UInt64: MeetingSummary]()
    private var _meetingPariticipantIDs = [UInt64: Set<UInt64>]()
    private var currentUserID: UInt64?
    
    private let meetingsSubject = CurrentValueSubject<[UInt64: Meeting], MeetingCoreError>([:])
    private let relatedMeetingIDsSubject = CurrentValueSubject<[UInt64: [UInt64]], Never>([:])
    private let meetingSummariesSubject = CurrentValueSubject<[UInt64: MeetingSummary], MeetingCoreError>([:])
    
    private let apiService: APIServable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        apiService: APIServable
    ) {
        self.apiService = apiService
        subscribe()
    }
    
    private func subscribe() {
        meetingsSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] dict in
                self?._meetings = dict
            }
            .store(in: &cancellables)
    }
}

// MARK: - MeetingCoreProtocol Confirmation
extension MeetingCore: MeetingCoreProtocol {
    var meetings: AnyPublisher<[UInt64 : Meeting], MeetingCoreError> {
        meetingsSubject.eraseToAnyPublisher()
    }
    
    var meetingSummaries: AnyPublisher<[UInt64: MeetingSummary], MeetingCoreError> {
        meetingSummariesSubject.eraseToAnyPublisher()
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
    
    func fetchMeeting(id: UInt64) -> Meeting? {
        _meetings[id]
    }
    
    func updateMeeting(id: UInt64, title: String?, description: String?, image: UIImage?) {
        
    }
    
    func endMeeting(id: UInt64) {
        
    }
    
    func exitMeeting(id: UInt64) {
        
    }
    
    func inviteParticipant(id: UInt64, participantId: UInt64) {
        
    }
    
    func acceptInvitation(id: UInt64) {
        
    }
}

// MARK: - MeetingMediationProtocol Conformation
extension MeetingCore: MeetingMediationProtocol {
    func friendListUpdated(meetingIDs: [UInt64: [UInt64]], summaries: [UInt64: MeetingSummary]) {
        relatedMeetingIDsSubject.send(meetingIDs)
        _summaries = summaries
    }
    
    func loadCurrentMeetingsWithFriend(friendID: UInt64) {
        guard let relatedMeetingIDs = relatedMeetingIDsSubject.value[friendID] else { return }
        let summaries = relatedMeetingIDs.reduce(into: [:]) { $0[$1] = _summaries[$1] }
        meetingSummariesSubject.send(summaries)
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
}
