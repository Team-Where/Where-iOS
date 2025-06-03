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
    @Published var selectedDate: Date?
    @Published var invitedFriends = [MeetingInvitationState]()
    @Published var watingFriends = [MeetingInvitationState]()
    @Published private var _meeting: Meeting!
    @Published var places = [Place]()
    
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
}
