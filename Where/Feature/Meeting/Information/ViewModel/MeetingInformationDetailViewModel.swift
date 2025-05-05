//
//  MeetingInformationDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/3/25.
//

import Foundation
import Combine
import Swinject

@MainActor
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
    private var cancellables = Set<AnyCancellable>()
    
    
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.invitationStatus
            .map { [weak self] dict -> [MeetingInvitationState] in
                guard let id = self?._meeting.id,
                      let states = dict[id]
                else { return [] }
                return states
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] status in
                self?.invitedFriends = status.filter { $0.isInvited }
                self?.watingFriends = status.filter { $0.isInvited == false }
            }
            .store(in: &cancellables)
        
        meetingCore.meetings
            .mapError {
                ViewModelError.meetingError($0)
            }
            .combineLatest($_meeting.setFailureType(to: ViewModelError.self))
            .compactMap{ (dict, meeting) -> Meeting? in
                guard let meeting else { return nil }
                return dict[meeting.id]
            }
            .sink { comletion in
                // TODO: Error handling
            } receiveValue: { [weak self] in
                self?._meeting = $0
            }
            .store(in: &cancellables)
        
        placeCore.places
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] dict in
                self?.places = dict.values.map { $0 }
            }
            .store(in: &cancellables)
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
        meetingCore.endMeeting(id: _meeting.id)
    }
}
