//
//  MeetingInformationDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/3/25.
//

import Foundation
import Combine

@MainActor
final class MeetingInformationDetailViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var isMeetingAvailiable = true
    @Published var meeting: Meeting?
    
    var isMeetingAvailable: Bool {
        meeting?.isFinished ?? true
    }
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        communityCore: CommunityCoreProtocol,
        meetingCore: MeetingCoreProtocol
    ) {
        self.communityCore = communityCore
        self.meetingCore = meetingCore
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.currentMeetingSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] meeting in
                self?.meeting = meeting
            }
            .store(in: &cancellables)
    }
}

// MARK: Interfaces
extension MeetingInformationDetailViewModel {
    func endMeeting() {
        guard let meetingId = meeting?.id else { return }
        meetingCore.endMeeting(id: meetingId)
    }
}
