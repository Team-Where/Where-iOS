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
    @Published var isSideMenuPresented = false
    @Published var isMeetingInformationViewPresented = false
    @Published var isLoginNeeded = false
    @Published var isRegistrationNeeded = false
    @Published var meetings: [Meeting] = []
    
    private let authCore: AuthentificationCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.meetings
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] dict in
                self?.meetings = dict.values.map { $0 }
                self?.sortMeetings(by: self?.sortType ?? .scheduled)
            }
            .store(in: &cancellables)
        
        $sortType
            .dropFirst()
            .sink { [weak self] type in
                self?.sortMeetings(by: type)
            }
            .store(in: &cancellables)
        
        authCore.authentificationState
            .map {
                guard case .registrationNeeded = $0 else { return false }
                return true
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] isNeeded in
                self?.isRegistrationNeeded = isNeeded
            }
            .store(in: &cancellables)
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
