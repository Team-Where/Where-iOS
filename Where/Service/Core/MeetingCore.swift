//
//  MeetingCore.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import Foundation
import Combine

protocol MeetingCoreProtocol: CoreProtocol {
    /// 나와 연관된 모임 목록
    var meetings: AnyPublisher<[UInt64: Meeting], MeetingCoreError> { get }
    /// 친구와 함께한 모임 목록
    var meetingSummaries: AnyPublisher<[UInt64: MeetingSummary], MeetingCoreError> { get }
    
    /// 모임 일정 등록
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func createSchedule(id: UInt64, date: Date, time: Date)
    /// 모임 일정 조회
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func readSchedule(id: UInt64)
    /// 모임 일정 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func updateSchedule(id: UInt64, date: Date, time: Date)
    /// 모임 일정 삭제
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func deleteSchedule(id: UInt64)
    /// 모임 생성
    /// - Parameters:
    ///     - info: 생성 중인 모임의 임시 정보
    func createMeeting(info: TemporaryMeetingInfo)
    /// 모임 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - imageData: 모임 대표 이미지 Data
    func updateMeeting(id: UInt64, imageData: Data?)
    /// 모임 종료
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func endMeeting(id: UInt64)
    /// 모임 탈퇴
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func exitMeeting(id: UInt64)
    /// 모임 초대 현황 조회
    ///  - Parameters:
    ///     - id: 모임의 고유 식별자
    func readInvitaionStatus(id: UInt64)
    /// 모임 초대
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - participantId: 초대 대상의 식별자
    func inviteParticipant(id: UInt64, hostName: String, guest: FriendRelationship)
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
    case encodingError(type: Encodable.Type)
    case noSuchMeeting
}

final class MeetingCore {
    weak var mediator: Notifiable?
    
    private var _meetings = [UInt64: Meeting]()
    private var _summaries = [UInt64: MeetingSummary]()
    private var _meetingPariticipantIDs = [UInt64: Set<UInt64>]()
    private var currentUserID: UInt64?
    
    /// 모임 관련 Subject
    /// - Key: meeting.id
    /// - Value: Meeting
    private let meetingsSubject = CurrentValueSubject<[UInt64: Meeting], MeetingCoreError>([:])
    
    private let relatedMeetingIDsSubject = CurrentValueSubject<[UInt64: [UInt64]], Never>([:])
    private let meetingSummariesSubject = CurrentValueSubject<[UInt64: MeetingSummary], MeetingCoreError>([:])
    private let invitationStatusSubject = CurrentValueSubject<[UInt64: [MeetingInvitationState]], MeetingCoreError>([:])
    
    private let apiService: APIServable
    private let encoder: JSONEncoder
    private var cancellables = Set<AnyCancellable>()
    
    init(
        apiService: APIServable,
        encoder: JSONEncoder
    ) {
        self.apiService = apiService
        self.encoder = encoder
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
    
    // MARK: - Schedule Related

    func createSchedule(id: UInt64, date: Date, time: Date) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(.userIDNotSet))
        }
        guard let meeting = _meetings[id]
        else {
            return meetingsSubject.send(completion: .failure(.noSuchMeeting))
        }

        let dto = CreateScheduleDTO.Request(meetingID: id, date: date.toString(by: .yyyyMMddHyphen), time: time.toString(by: .HHmm), userID: userID)
        apiService.requestPublisher(Endpoint.createSchedule(dto: dto), CreateScheduleDTO.Response.self)
            .map {
                Meeting(
                    id: id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    updatedAt: meeting.updatedAt,
                    scheduleDate: $0.date.toDate(by: .yyyyMMddHyphen),
                    scheduleTime: $0.time.toDate(by: .HHmm),
                    shareLink: meeting.shareLink,
                    isFinished: meeting.isFinished
                )
            }
            .sink { completion in
                // TODO: Error handling
            } receiveValue: { [weak self] newMeeting in
                guard let self else { return }
                var meetings = meetingsSubject.value
                meetings[id] = newMeeting
                meetingsSubject.send(meetings)
            }
            .store(in: &cancellables)
    }
    
    func readSchedule(id: UInt64) {
        
    }
    
    func updateSchedule(id: UInt64, date: Date, time: Date) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(.userIDNotSet))
        }
        guard let meeting = _meetings[id]
        else {
            return meetingsSubject.send(completion: .failure(.noSuchMeeting))
        }

        let dto = UpdateScheduleDTO.Request(meetingID: id, date: date.toString(by: .yyyyMMddHyphen), time: time.toString(by: .HHmm), userID: userID)
        apiService.requestPublisher(Endpoint.updateSchedule(dto: dto), UpdateScheduleDTO.Response.self)
            .map {
                Meeting(
                    id: id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    updatedAt: meeting.updatedAt,
                    scheduleDate: $0.date.toDate(by: .yyyyMMddHyphen),
                    scheduleTime: $0.time.toDate(by: .HHmm),
                    shareLink: meeting.shareLink,
                    isFinished: meeting.isFinished
                )
            }
            .sink { completion in
                // TODO: Error handling
            } receiveValue: { [weak self] newMeeting in
                guard let self else { return }
                var meetings = meetingsSubject.value
                meetings[id] = newMeeting
                meetingsSubject.send(meetings)
            }
            .store(in: &cancellables)
    }
    
    func deleteSchedule(id: UInt64) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(.userIDNotSet))
        }
        guard let meeting = _meetings[id]
        else {
            return meetingsSubject.send(completion: .failure(.noSuchMeeting))
        }
                
        let dto = DeleteScheduleDTO.Request(meetingID: id, userID: userID)
        apiService.requestPublisher(Endpoint.deleteSchedule(dto: dto), EmptyDTO.Response.self)
            .map { _ in
                Meeting(
                    id: id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    updatedAt: meeting.updatedAt,
                    shareLink: meeting.shareLink,
                    isFinished: meeting.isFinished
                )
            }
            .sink { completion in
                // TODO: Error handling
            } receiveValue: { [weak self] newMeeting in
                guard let self else { return }
                var meetings = meetingsSubject.value
                meetings[id] = newMeeting
                meetingsSubject.send(meetings)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Meeting Related

    func createMeeting(info: TemporaryMeetingInfo) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(.userIDNotSet))
        }
        
        do {
            let dto = CreateMeetingDTO.Request(title: info.title, creatorID: userID, description: info.description, participants: info.participants)
            let encodedMeeting = try encoder.encode(dto)
            let imageData = info.imageData
            
            apiService.requestPublisher(Endpoint.createMeeting(encodedMeetingData: encodedMeeting, imageData: imageData), CreateMeetingDTO.Response.self)
                .map { $0.toEntity() }
                .sink { completion in
                    // TODO: error handling
                } receiveValue: { [weak self] meeting in
                    guard let self else { return }
                    var meetings = meetingsSubject.value
                    meetings[meeting.id] = meeting
                    meetingsSubject.send(meetings)
                }
                .store(in: &cancellables)
        } catch {
            meetingsSubject.send(completion: .failure(.encodingError(type: CreateMeetingDTO.Request.self)))
        }
    }
    
    func updateMeeting(id: UInt64, imageData: Data?) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(.userIDNotSet))
        }
        
        guard let meeting = _meetings[id]
        else {
            return meetingsSubject.send(completion: .failure(.noSuchMeeting))
        }
        
        let dto = UpdateMeetingDTO.Request(meetingID: id, title: meeting.title, description: meeting.description, userID: userID)
        do {
            let encodedMeetingData = try encoder.encode(dto)
            apiService.requestPublisher(Endpoint.updateMeeting(encodedMeetingData: encodedMeetingData, imageData: imageData), UpdateMeetingDTO.Response.self)
                .map {
                    Meeting(
                        id: meeting.id,
                        title: $0.title,
                        description: $0.description,
                        imageURL: URL(string: $0.imageURLString ?? ""),
                        shareLink: URL(string: $0.invitationLink),
                        isFinished: meeting.isFinished
                    )
                }
                .sink { completion in
                    // TODO: Error 핸들링 강화
                } receiveValue: { [weak self] newMeeting in
                    guard let self else { return }
                    var meetings = meetingsSubject.value
                    meetings[meeting.id] = newMeeting
                    meetingsSubject.send(meetings)
                }
                .store(in: &cancellables)
        } catch {
            meetingsSubject.send(completion: .failure(MeetingCoreError.encodingError(type: UpdateMeetingDTO.Request.self)))
        }
    }
    
    func endMeeting(id: UInt64) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(.userIDNotSet))
        }
        guard let meeting = _meetings[id]
        else {
            return meetingsSubject.send(completion: .failure(.noSuchMeeting))
        }
        let dto = EndMeetingDTO.Request(meetingID: id, userID: userID)
        apiService.requestPublisher(Endpoint.endMeeting(dto: dto), EmptyDTO.Response.self)
            .map { _ in
                Meeting(
                    id: meeting.id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    updatedAt: meeting.updatedAt,
                    scheduleDate: meeting.scheduleDate,
                    scheduleTime: meeting.scheduleTime,
                    shareLink: meeting.shareLink,
                    isFinished: true
                )
            }
            .sink { completion in
                //TODO: Error handling
            } receiveValue: { [weak self] endedMeeting in
                guard let self else { return }
                var meetngs = meetingsSubject.value
                meetngs[id] = endedMeeting
                meetingsSubject.send(meetngs)
            }
            .store(in: &cancellables)

    }
    
    func exitMeeting(id: UInt64) {
        guard let userID = currentUserID
        else {
            return meetingsSubject.send(completion: .failure(MeetingCoreError.userIDNotSet))
        }
        let dto = LeaveMeetingDTO.Request(meetingID: id, userID: userID)
        apiService.requestPublisher(Endpoint.leaveMeeting(dto: dto), EmptyDTO.Response.self)
            .sink { completion in
                //TODO: Error handling
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                var meetings = meetingsSubject.value
                meetings.removeValue(forKey: id)
                meetingsSubject.send(meetings)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Invitation Related

    func readInvitaionStatus(id: UInt64) {
        guard let _ = currentUserID
        else {
            return invitationStatusSubject.send(completion: .failure(.userIDNotSet))
        }
        apiService.requestPublisher(Endpoint.readInvitationStatus(meetingID: id), ReadInvitationStatusDTO.Response.self)
            .map { response in
                response.map { $0.toEntity() }
            }
            .sink { completion in
                //TODO: Error handling
            } receiveValue: { [weak self] invitaionState in
                guard let self else { return }
                var newInvitationStatusDict = invitationStatusSubject.value
                newInvitationStatusDict[id] = invitaionState
                invitationStatusSubject.send(newInvitationStatusDict)
            }
            .store(in: &cancellables)
    }
    
    func inviteParticipant(id: UInt64, hostName: String, guest: FriendRelationship) {
        guard let userID = currentUserID
        else {
            return invitationStatusSubject.send(completion: .failure(.userIDNotSet))
        }
        let dto = InviteFriendsDTO.Request(meetingID: id, hostID: userID, guestID: guest.id)
        apiService.requestPublisher(Endpoint.inviteFriends(dto: dto), EmptyDTO.Response.self)
            .map { _ in
                MeetingInvitationState(
                    hostID: userID,
                    hostName: hostName,
                    guestID: guest.id,
                    guestName: guest.nickname,
                    status: false,
                    guestImageURLString: guest.imageURL?.absoluteString
                )
            }
            .sink { completion in
                // TODO: Error handling
            } receiveValue: { [weak self] invitationState in
                guard let self else { return }
                var status = invitationStatusSubject.value
                status[id]?.append(invitationState)
                invitationStatusSubject.send(status)
            }
            .store(in: &cancellables)
    }
    
    func acceptInvitation(id: UInt64) {
        guard let _ = currentUserID
        else {
            return invitationStatusSubject.send(completion: .failure(.userIDNotSet))
        }
        let dto = AcceptMeeetingInvitationDTO.Request(invitationID: id)
        apiService.requestPublisher(Endpoint.acceptMeeetingInvitation(dto: dto), AcceptMeeetingInvitationDTO.Response.self)
            .map { $0.toEntity() }
            .sink { completion in
                // TODO: 에러핸들링 강화
            } receiveValue: { [weak self] meeting in
                guard let self else { return }
                var meetings = meetingsSubject.value
                meetings[meeting.id] = meeting
                meetingsSubject.send(meetings)
            }
            .store(in: &cancellables)
    }
}

// MARK: - MeetingMediationProtocol Conformation
extension MeetingCore: MeetingMediationProtocol {
    func updateRelatedMeetings(meetingIDs: [UInt64 : [UInt64]], summaries: [UInt64 : MeetingSummary]) {
        return
    }
    
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
