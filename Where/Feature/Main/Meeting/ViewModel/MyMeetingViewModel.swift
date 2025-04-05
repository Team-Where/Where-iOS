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
    @Published var isCompleteCreationViewPresented: Bool = false
    @Published var isSideMenuPresented: Bool = false
    @Published var isMeetingInformationViewPresented: Bool = false
    @Published var meetings: [Meeting] = []
    
    private let community: CommunityCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(community: CommunityCoreProtocol) {
        self.community = community
        subscribe()
    }
    
    private func subscribe() {
        community.meetings
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
    }
    
    private func sortMeetings(by type: MeetingSortType) {
        switch type {
        case .created:
            meetings.sort { $0.createdAt < $1.createdAt }
        case .scheduled:
            meetings.sort { lhs, rhs in
                // MARK: 정렬 기준 구체화 예정 (WIP)
                let isLeftFinished = lhs.schedule ?? .now < .now
                let isRightFinished = rhs.schedule ?? .now < .now
                
                if isLeftFinished && !isRightFinished {
                    return false
                } else if !isLeftFinished && isRightFinished {
                    return true
                } else {
                    return lhs.schedule ?? .now < rhs.schedule ?? .now
                }
            }
        }
    }
}

// MARK: Interfaces
extension MyMeetingViewModel {
    func toggleSideMenuPresentation() {
        isSideMenuPresented.toggle()
    }
    
    func selectSortType(for type: MeetingSortType) {
        sortType = type
    }
    
    func routeToMeetingInformationView(meeting: Meeting) {
        community.readCurrentMeeting(id: meeting.id)
        isMeetingInformationViewPresented = true
    }
}
