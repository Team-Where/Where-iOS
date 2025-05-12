//
//  MyMeetingViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/1/25.
//

import Foundation
import Combine
import Swinject

final class MyMeetingViewModel: ObservableObject {
    @Published var sortType: MeetingSortType = .created
    @Published var isMeetingInformationViewPresented = false
    @Published var isLoginNeeded: Bool = false
    @Published var isSideMenuPresented: Bool = false
    @Published var isRegistrationNeeded = false
    @Published var meetings: [Meeting] = []
    
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
        
        $sortType
            .dropFirst()
            .sink { [weak self] type in
                self?.sortMeetings(by: type)
            }
            .store(in: cancellableBag, key: "SortType")
        
        authCore.authentificationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loginCompleted:
                    self?.isLoginNeeded = false
                    
                case .registrationNeeded:
                    self?.isLoginNeeded = false
                    self?.isRegistrationNeeded = true
                    
                case .loginNeeded:
                    break
                }
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
    func toggleSideMenuPresentation() {
        isSideMenuPresented.toggle()
    }
    
    func presentLoginView() {
        isLoginNeeded = true
    }
    
    func selectSortType(for type: MeetingSortType) {
        sortType = type
    }
    
    func routeToMeetingInformationView(meeting: Meeting) {
        isMeetingInformationViewPresented = true
    }
}
