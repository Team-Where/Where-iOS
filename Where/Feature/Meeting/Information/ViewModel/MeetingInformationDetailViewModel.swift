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
    @Published var isMeetingAvailiable = true
    @Published var meeting: Meeting?
    
    var isMeetingAvailable: Bool {
        meeting?.isFinished ?? true
    }
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.currentMeeting
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] meeting in
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
