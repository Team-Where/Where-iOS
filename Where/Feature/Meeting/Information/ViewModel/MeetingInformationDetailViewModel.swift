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
    
    private var meeting: Meeting?
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.invitationStatus
            .map { [weak self] dict -> [MeetingInvitationState] in
                guard let id = self?.meeting?.id,
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
    }
}

// MARK: Interfaces
extension MeetingInformationDetailViewModel {
    func onAppear(meeting: Meeting) {
        self.meeting = meeting
    }
    
    func endMeeting() {
        guard let meetingId = meeting?.id else { return }
        meetingCore.endMeeting(id: meetingId)
    }
}
