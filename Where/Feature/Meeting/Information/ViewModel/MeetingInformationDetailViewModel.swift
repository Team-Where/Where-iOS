//
//  MeetingInformationDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/3/25.
//

import Foundation
import Combine
import Swinject

final class MeetingInformationDetailViewModel: ObservableObject {
    @Published var invitedFriends = [MeetingInvitationState]()
    @Published var watingFriends = [MeetingInvitationState]()
    @Published var places = [Place]()
    @Published private var _meeting: Meeting!
    @Published private(set) var processingState: ProcessingState = .waiting
    
    var meeting: Meeting {
        _meeting
    }
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.invitationStatus
            .combineLatest($_meeting)
            .map { (dict, meeting) -> [MeetingInvitationState] in
                guard let id = meeting?.id,
                      let states = dict[id]
                else { return [] }
                return states
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { [weak self] status in
                self?.invitedFriends = status.filter { $0.isInvited }
                self?.watingFriends = status.filter { $0.isInvited == false }
            }
            .store(in: cancellableBag, key: "InvitationStatus")
        
        meetingCore.meetings
            .combineLatest($_meeting)
            .compactMap{ (dict, meeting) -> Meeting? in
                guard let meeting else { return nil }
                return dict[meeting.id]
            }
            .sink { [weak self] in
                self?._meeting = $0
            }
            .store(in: cancellableBag, key: "Meetings")
        
        placeCore.places
            .sink { [weak self] dict in
                self?.places = dict.values.map { $0 }
            }
            .store(in: cancellableBag, key: "Places")
    }
}

// MARK: - Nested Types
extension MeetingInformationDetailViewModel {
    /// 비동기 요청 진행 상태
    enum ProcessingState {
        /// 대기 중 (아무 작업도 요청되지 않았을 때)
        case waiting
        /// 처리 중
        case processing
        /// 작업 완료
        case completed
        /// 에러 발생
        case errorOccured
    }
}

// MARK: Interfaces
extension MeetingInformationDetailViewModel {
    func setMeeitng(_ meeting: Meeting) {
        self._meeting = meeting
    }
    
    func onAppear() {
        meetingCore.readInvitaionStatus(id: _meeting.id)
    }
    
    func endMeeting() {
        cancellableBag[#function] = meetingCore.endMeeting(id: _meeting.id)
            .sink { completion in
                
            } receiveValue: { _ in
                // 별도의 완료 처리는 없음
            }
    }
    
    func editSchedule(_ date: Date?, _ time: Date?) {
        processingState = .processing
        
        Just(meeting)
            .flatMap { [meetingCore] meeting in
                switch (meeting.scheduleDate, meeting.scheduleTime, date, time) {
                case (.none, .none, .some(let newDate), .some(let newTime)):
                    let dateString = newDate.toString(by: .yyyyMMddHyphen)
                    let timeString = newTime.toString(by: .HHmm)
                    return meetingCore.createSchedule(id: meeting.id, date: dateString, time: timeString)
                    
                case (.some, .some, .some(let newDate), .some(let newTime)):
                    let dateString = newDate.toString(by: .yyyyMMddHyphen)
                    let timeString = newTime.toString(by: .HHmm)
                    return meetingCore.updateSchedule(id: meeting.id, date: dateString, time: timeString)
                    
                case (.some, .some, .none, .none):
                    return meetingCore.deleteSchedule(id: meeting.id)
                    
                default:
                    return Fail<Void, MeetingCoreError>(error: MeetingCoreError.notSupported).eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: self?.processingState = .completed
                case .failure: self?.processingState = .errorOccured
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}
