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
    var meetings: AnyPublisher<[UInt64: Meeting], Never> { get }
    /// 친구와 함께한 모임 목록
    var meetingSummaries: AnyPublisher<[UInt64: MeetingSummary], Never> { get }
    /// 친구와 연관된 모임 식별자
    var relatedMeetingIDs: AnyPublisher<[UInt64: [UInt64]], Never> { get }
    /// 특정 모임의 초대 현황
    var invitationStatus: AnyPublisher<[UInt64: [MeetingInvitationState]], Never> { get }
    /// 초대 받은 모임 정보
    var invitedMeeting: AnyPublisher<(name: String, meeting: Meeting), Never> { get }
    /// 새로 생성된 모임 정보
    var createdMeeting: AnyPublisher<Meeting, Never> { get }
    /// 모임 일정 등록
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func createSchedule(id: UInt64, date: String, time: String) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 일정 조회
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func readSchedule(id: UInt64)
    /// 모임 일정 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func updateSchedule(id: UInt64, date: String, time: String) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 일정 삭제
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func deleteSchedule(id: UInt64) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 생성
    /// - Parameters:
    ///     - info: 생성 중인 모임의 임시 정보
    func createMeeting(info: TemporaryMeetingInfo) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - title: 모임의 제목
    ///     - description: 모임의 메모 및 설명
    ///     - imageData: 모임 대표 이미지 Data
    func updateMeeting(id: UInt64, title: String?, description: String?, imageData: Data?) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 종료
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func endMeeting(id: UInt64) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 탈퇴
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func exitMeeting(id: UInt64) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 초대 현황 조회
    ///  - Parameters:
    ///     - id: 모임의 고유 식별자
    func readInvitationStatus(id: UInt64)
    /// 모임 초대
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - participantId: 초대 대상의 식별자
    func inviteParticipant(id: UInt64, guest: FriendRelationship) -> AnyPublisher<Void, MeetingCoreError>
    /// 카카오톡으로 모임 초대
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func inviteParticipantWithKakao(id: UInt64) -> AnyPublisher<URL, MeetingCoreError>
    /// 모임 초대 수락
    /// - Parameters:
    ///     - id: 초대장 식별자
    func acceptInvitation(id: UInt64) -> AnyPublisher<Void, MeetingCoreError>
    /// 모임 초대 수락 링크
    /// - Parameters:
    func acceptInvitationByLinkCode() -> AnyPublisher<Void, MeetingCoreError>
    /// 초대장 링크로 모임 정보 조회
    /// - Parameters
    ///     - inviterName: 초대한 사용자의 닉네임
    ///     - invitedCode: 초대 고유 코드
    func readMeetingDetailForInvitationLink(inviterName: String, inviteCode: String)
    /// 미수락 모임 초대 목록 조회
    func readPendingMeetingInvitation() -> AnyPublisher<[PendingMeeting], MeetingCoreError>
}

protocol MeetingMediationProtocol {
    /// 친구와 함께한 모임 목록 갱신을 지시, 중재자에 의해 호출됨
    func updateRelatedMeetings(meetingIDs: [UInt64: [UInt64]], summaries: [UInt64: MeetingSummary])
    /// 특정 친구와 함께한 모임 목록 로드를 지시, 중재자에 의해 호출됨
    func loadCurrentMeetingsWithFriend(friendID: UInt64)
    /// 현재 사용자를 설정, 중재자에 의해 호출됨
    func setCurrentUser(_ user: User?)
    /// 전체 모임 조회, 중재자에 의해 호출
    func loadAllMeetings()
    /// 사용자 로그아웃 시 작업 수행을 지시, 중재자에 의해 호출됨
    func userDidLogout()
    /// 모임 초대 알림 터치시 발생할 이벤트, 중재자에 의해 호출 됨.
    func perfomInAppMeetingInvitation(inviterName: String, meeting: Meeting)
}

enum MeetingCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
    case encodingError(type: Encodable.Type)
    case noSuchMeeting
    case notSupported
}

final class MeetingCore {
    weak var mediator: Notifiable?
    
    private var _meetings = [UInt64: Meeting]()
    private var _summaries = [UInt64: MeetingSummary]()
    private var _meetingPariticipantIDs = [UInt64: Set<UInt64>]()
    private var currentUser: User?
    private var currentInviteCode: String?
    
    /// 모임 관련 Subject
    /// - Key: meeting.id
    /// - Value: Meeting
    private let meetingsSubject = CurrentValueSubject<[UInt64: Meeting], Never>([:])
    
    private let relatedMeetingIDsSubject = CurrentValueSubject<[UInt64: [UInt64]], Never>([:])
    private let meetingSummariesSubject = CurrentValueSubject<[UInt64: MeetingSummary], Never>([:])
    private let invitationStatusSubject = CurrentValueSubject<[UInt64: [MeetingInvitationState]], Never>([:])
    private let invitedMeetingSubject = PassthroughSubject<(name: String, meeting: Meeting), Never>()
    private let createdMeetingSubject = PassthroughSubject<Meeting, Never>()
    
    private let apiService: APIServable
    private let kakaoShareService: KakaoShareServiceProtocol
    private let encoder: JSONEncoder
    private let cancellableBag = CancellableBag()
    
    init(
        apiService: APIServable,
        kakaoShareService: KakaoShareServiceProtocol,
        encoder: JSONEncoder
    ) {
        self.apiService = apiService
        self.kakaoShareService = kakaoShareService
        self.encoder = encoder
        subscribe()
    }
    
    private func subscribe() {
        meetingsSubject
            .sink { [weak self] dict in
                self?._meetings = dict
            }
            .store(in: cancellableBag, key: "MeetingsSubject")
    }
}

// MARK: - MeetingCoreProtocol Confirmation
extension MeetingCore: MeetingCoreProtocol {
    var meetings: AnyPublisher<[UInt64 : Meeting], Never> {
        meetingsSubject.eraseToAnyPublisher()
    }
    
    var meetingSummaries: AnyPublisher<[UInt64: MeetingSummary], Never> {
        meetingSummariesSubject.eraseToAnyPublisher()
    }
    
    var relatedMeetingIDs: AnyPublisher<[UInt64 : [UInt64]], Never> {
        relatedMeetingIDsSubject.eraseToAnyPublisher()
    }
    
    var invitationStatus: AnyPublisher<[UInt64 : [MeetingInvitationState]], Never> {
        invitationStatusSubject.eraseToAnyPublisher()
    }
    
    var invitedMeeting: AnyPublisher<(name: String, meeting: Meeting), Never> {
        invitedMeetingSubject.eraseToAnyPublisher()
    }
    
    var createdMeeting: AnyPublisher<Meeting, Never> {
        createdMeetingSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Schedule Related
    
    func createSchedule(id: UInt64, date: String, time: String) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        guard let meeting = _meetings[id] else {
            return Fail(error: .noSuchMeeting).eraseToAnyPublisher()
        }
        
        let dto = CreateScheduleDTO.Request(meetingID: id, date: date, time: time, userID: user.id)
        
        return apiService.requestPublisher(Endpoint.createSchedule(dto: dto), CreateScheduleDTO.Response.self)
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] response in
                let newMeeting = Meeting(
                    id: id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    scheduleDate: response.date.toDate(by: .yyyyMMddHyphen),
                    scheduleTime: response.time.toDate(by: .HHmm),
                    shareLink: meeting.shareLink,
                    isFinished: meeting.isFinished
                )
                
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[id] = newMeeting
                self?.meetingsSubject.send(meetings)
            }
            .eraseToAnyPublisher()
    }
    
    func readSchedule(id: UInt64) {
        
    }
    
    func updateSchedule(id: UInt64, date: String, time: String) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        guard let meeting = _meetings[id] else {
            return Fail(error: .noSuchMeeting).eraseToAnyPublisher()
        }
        
        let dto = UpdateScheduleDTO.Request(meetingID: id, date: date, time: time, userID: user.id)
        return apiService.requestPublisher(Endpoint.updateSchedule(dto: dto), UpdateScheduleDTO.Response.self)
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] response in
                let newMeeting = Meeting(
                    id: id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    scheduleDate: response.date.toDate(by: .yyyyMMddHyphen),
                    scheduleTime: response.time.toDate(by: .HHmm),
                    shareLink: meeting.shareLink,
                    isFinished: meeting.isFinished
                )
                
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[id] = newMeeting
                self?.meetingsSubject.send(meetings)
                self?.mediator?.notify(event: .updateMeetingSchedule(meeting: newMeeting))
            }
            .eraseToAnyPublisher()
    }
    
    func deleteSchedule(id: UInt64) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        guard let meeting = _meetings[id] else {
            return Fail(error: .noSuchMeeting).eraseToAnyPublisher()
        }
        
        let dto = DeleteScheduleDTO.Request(meetingID: id, userID: user.id)
        return apiService.requestVoidPublisher(Endpoint.deleteSchedule(dto: dto))
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] _ in
                let newMeeting = Meeting(
                    id: id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    shareLink: meeting.shareLink,
                    isFinished: meeting.isFinished
                )
                
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[id] = newMeeting
                self?.meetingsSubject.send(meetings)
                self?.mediator?.notify(event: .removeNotification(id: id))
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Meeting Related
    
    func createMeeting(info: TemporaryMeetingInfo) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = CreateMeetingDTO.Request(title: info.title, creatorID: user.id, description: info.description, participants: info.participants)
        let imageData = info.imageData
        guard let encodedMeeting = try? encoder.encode(dto) else {
            return Fail(error: .encodingError(type: CreateMeetingDTO.Request.self)).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.createMeeting(encodedMeetingData: encodedMeeting, imageData: imageData), CreateMeetingDTO.Response.self)
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] response in
                let newMeeting = response.toEntity()
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[newMeeting.id] = newMeeting
                self?.meetingsSubject.send(meetings)
                self?.createdMeetingSubject.send(newMeeting)
            }
            .eraseToAnyPublisher()
    }
    
    func updateMeeting(id: UInt64, title: String?, description: String?, imageData: Data?) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        guard let meeting = _meetings[id] else {
            return Fail(error: .noSuchMeeting).eraseToAnyPublisher()
        }
        
        let dto = UpdateMeetingDTO.Request(
            meetingID: id,
            title: title,
            description: description,
            userID: user.id
        )
        
        guard let encodedMeetingData = try? encoder.encode(dto) else {
            return Fail(error: .encodingError(type: UpdateMeetingDTO.Request.self)).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.updateMeeting(encodedMeetingData: encodedMeetingData, imageData: imageData), UpdateMeetingDTO.Response.self)
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] in
                let newMeeting = Meeting(
                    id: meeting.id,
                    title: $0.title,
                    description: $0.description,
                    imageURL: URL(string: $0.imageURLString ?? ""),
                    createdAt: meeting.createdAt,
                    shareLink: URL(string: $0.invitationLink),
                    isFinished: meeting.isFinished
                )
                
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[newMeeting.id] = newMeeting
                self?.meetingsSubject.send(meetings)
            }
            .eraseToAnyPublisher()
    }
    
    func endMeeting(id: UInt64) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        guard let meeting = _meetings[id] else {
            return Fail(error: .noSuchMeeting).eraseToAnyPublisher()
        }
        
        let dto = EndMeetingDTO.Request(meetingID: id, userID: user.id)
        return apiService.requestVoidPublisher(Endpoint.endMeeting(dto: dto))
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] _ in
                let endedMeeting = Meeting(
                    id: meeting.id,
                    title: meeting.title,
                    description: meeting.description,
                    imageURL: meeting.imageURL,
                    createdAt: meeting.createdAt,
                    scheduleDate: meeting.scheduleDate,
                    scheduleTime: meeting.scheduleTime,
                    shareLink: meeting.shareLink,
                    isFinished: true
                )
                
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[id] = endedMeeting
                self?.meetingsSubject.send(meetings)
            }
            .eraseToAnyPublisher()
    }
    
    func exitMeeting(id: UInt64) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = LeaveMeetingDTO.Request(meetingID: id, userID: user.id)
        return apiService.requestVoidPublisher(Endpoint.leaveMeeting(dto: dto))
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] _ in
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings.removeValue(forKey: id)
                self?.meetingsSubject.send(meetings)
                self?.mediator?.notify(event: .removeNotification(id: id))
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Invitation Related

    func readInvitationStatus(id: UInt64) {
        guard let _ = currentUser else { return }
        
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.readInvitationStatus(meetingID: id), ReadInvitationStatusDTO.Response.self)
            .map { response in
                response.map { $0.toEntity() }
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] invitaionState in
                guard let self else { return }
                var newInvitationStatusDict = invitationStatusSubject.value
                newInvitationStatusDict[id] = invitaionState
                invitationStatusSubject.send(newInvitationStatusDict)
            }
    }
    
    func inviteParticipant(id: UInt64, guest: FriendRelationship) -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser,
              let nickname = user.nickname
        else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = InviteFriendsDTO.Request(meetingID: id, hostID: user.id, guestID: guest.id)
        
        return apiService.requestVoidPublisher(Endpoint.inviteFriends(dto: dto))
            .map { _ in () }
            .handleEvents(receiveOutput: { [weak self] _ in
                let state = MeetingInvitationState(
                    hostID: user.id,
                    hostName: nickname,
                    guestID: guest.id,
                    guestName: guest.nickname,
                    isInvited: true,
                    isAccepted: false,
                    guestImageURLString: guest.imageURL?.absoluteString
                )
                
                guard var status = self?.invitationStatusSubject.value else { return }
                status[id]?.append(state)
                self?.invitationStatusSubject.send(status)
            })
            .mapError { MeetingCoreError.networkingError($0) }
            .eraseToAnyPublisher()
    }
    
    func inviteParticipantWithKakao(id: UInt64) -> AnyPublisher<URL, MeetingCoreError> {
        guard let inviter = currentUser else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        guard let meeting = meetingsSubject.value[id] else {
            return Fail(error: .noSuchMeeting).eraseToAnyPublisher()
        }
        
        return kakaoShareService.share(inviter: inviter, meeting: meeting)
    }
    
    func acceptInvitation(id: UInt64) -> AnyPublisher<Void, MeetingCoreError> {
        guard let _ = currentUser
        else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = AcceptMeeetingInvitationDTO.Request(invitationID: id)
        return apiService.requestPublisher(Endpoint.acceptMeeetingInvitation(dto: dto), AcceptMeeetingInvitationDTO.Response.self)
            .mapError { MeetingCoreError.networkingError($0) }
            .map { [weak self] response in
                let newMeeting = response.toEntity()
                guard var meetings = self?.meetingsSubject.value else { return }
                meetings[newMeeting.id] = newMeeting
                self?.meetingsSubject.send(meetings)
                self?.mediator?.notify(event: .updateMeetingSchedule(meeting: newMeeting))
            }
            .eraseToAnyPublisher()
    }
    
    func acceptInvitationByLinkCode() -> AnyPublisher<Void, MeetingCoreError> {
        guard let user = currentUser,
              let code = currentInviteCode
        else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
                
        let dto = AcceptMeetingInvitationByLinkDTO.Request(userID: user.id, invitationLink: code)
        return apiService.requestPublisher(Endpoint.acceptMeetingInvitationByLink(dto: dto), AcceptMeetingInvitationByLinkDTO.Response.self)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self else { return }
                let newMeeting = response.toEntity()
                var meetings = meetingsSubject.value
                meetings[newMeeting.id] = newMeeting
                meetingsSubject.send(meetings)
            })
            .mapError { MeetingCoreError.networkingError($0) }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func readMeetingDetailForInvitationLink(inviterName: String, inviteCode: String) {
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.readMeetingDetailForInvitationLink(inviteCode: inviteCode), MeetingDetailFromLinkDTO.Response.self)
            .map {
                $0.toEntity()
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] in
                self?.currentInviteCode = inviteCode
                self?.invitedMeetingSubject.send((inviterName, $0))
            }
    }
    
    func readPendingMeetingInvitation() -> AnyPublisher<[PendingMeeting], MeetingCoreError> {
        guard let user = currentUser
        else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        return apiService.requestPublisher(Endpoint.pendingMeetingInvites(userID: user.id), PendingMeetingInvitesDTO.Response.self)
            .mapError {
                MeetingCoreError.networkingError($0)
            }
            .map {
                $0.map { $0.toEntity() }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - MeetingMediationProtocol Conformation
extension MeetingCore: MeetingMediationProtocol {
    func loadAllMeetings() {
        guard let user = currentUser else { return }
        
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.readMeetingDetail(userID: user.id), ReadMeetingDetailDTO.Response.self)
            .map { meetings in
                meetings.reduce(into: [:]) { [weak self] in
                    let meeting = $1.toEntity()
                    self?.mediator?.notify(event: .updateMeetingSchedule(meeting: meeting))
                    $0[$1.meetingID] = meeting
                }
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] in
                self?.meetingsSubject.send($0)
            }
    }
    
    func updateRelatedMeetings(meetingIDs: [UInt64 : [UInt64]], summaries: [UInt64 : MeetingSummary]) {
        relatedMeetingIDsSubject.send(meetingIDs)
        _summaries = summaries
    }
    
    func loadCurrentMeetingsWithFriend(friendID: UInt64) {
        guard let relatedMeetingIDs = relatedMeetingIDsSubject.value[friendID] else { return }
        let summaries = relatedMeetingIDs.reduce(into: [:]) { $0[$1] = _summaries[$1] }
        meetingSummariesSubject.send(summaries)
    }
    
    func setCurrentUser(_ user: User?) {
        currentUser = user
    }
    
    func userDidLogout() {
        currentUser = nil
        meetingsSubject.send([:])
        relatedMeetingIDsSubject.send([:])
        meetingSummariesSubject.send([:])
        invitationStatusSubject.send([:])
    }
    
    func perfomInAppMeetingInvitation(inviterName: String, meeting: Meeting) {
        invitedMeetingSubject.send((inviterName, meeting))
    }
}
