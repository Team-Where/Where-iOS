//
//  MyMeetingViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/1/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class MyMeetingViewModel {
    private(set) var sortType: MeetingSortType = .created
    private(set) var isRegistrationNeeded: Bool = false
    var meetings: [Meeting] = []
    
    private let authCore: AuthentificationCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.meetings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.meetings = dict.values.map { $0 }
                self?.sortMeetings(by: self?.sortType ?? .scheduled)
            }
            .store(in: cancellableBag, key: "Meetings")
        
        authCore.authentificationState
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard case .registrationNeeded = state else { return }
                self?.isRegistrationNeeded = true
            }
            .store(in: cancellableBag, key: "AuthentificationState")
    }
    
    private func sortMeetings(by type: MeetingSortType) {
        switch type {
        case .created:
            meetings.sort { $0.createdAt < $1.createdAt }
        case .scheduled:
            meetings.sort { $0.scheduleDate ?? .now < $1.scheduleDate ?? .now }
        }
    }
}

// MARK: Interfaces
extension MyMeetingViewModel {
    func selectSortType(for type: MeetingSortType) {
        sortType = type
        sortMeetings(by: type)
    }
}
