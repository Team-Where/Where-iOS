//
//  ContentViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import Foundation
import Combine
import Swinject

final class TabViewSelection: ObservableObject {
    /// 탭 뷰의 탭아이템 종류
    enum TabItem: Hashable {
        case myMeeting
        case createMeeting
        case friendsList
    }
    
    @Published var selectedTab: TabItem = .myMeeting
    private var previousTab: TabItem = .myMeeting
    
    func selectTab(_ tabItem: TabItem) {
        previousTab = selectedTab
        selectedTab = tabItem
    }
}

@Observable
final class ContentViewModel {
    private(set) var isLoginNeeded: Bool = true
    private(set) var isRegistrationNeeded: Bool = false
    private var _user: User?
    private var _meetings: [Meeting] = []
    private var _sortType: MeetingSortType = .created
    
    
    private let authCore: AuthentificationCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.authentificationState
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loginNeeded:
                    self?.isLoginNeeded = true
                case .registrationNeeded:
                    self?.isRegistrationNeeded = true
                case .loginCompleted(let user):
                    self?._user = user
                    self?.isLoginNeeded = false
                }
            }
            .store(in: cancellableBag, key: "AuthentificationState")
        
        meetingCore.meetings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?._meetings = dict.values.map { $0 }
                self?.sortMeetings(by: self?.sortType ?? .scheduled)
            }
            .store(in: cancellableBag, key: "Meetings")
        
    }
    
    private func sortMeetings(by type: MeetingSortType) {
        switch type {
        case .created:
            _meetings.sort { $0.createdAt < $1.createdAt }
        case .scheduled:
            _meetings.sort { $0.scheduleDate ?? .now < $1.scheduleDate ?? .now }
        }
    }
}

// MARK: - Interfaces
extension ContentViewModel: MyMeetingViewModelType {
    var user: User? { _user }
    
    var meetings: [Meeting] {
        _meetings
    }
    
    var sortType: MeetingSortType {
        _sortType
    }
    
    func selectSortType(for type: MeetingSortType) {
        _sortType = type
        sortMeetings(by: type)
    }
}


protocol MyMeetingViewModelType {
    var user: User? { get }
    var meetings: [Meeting] { get }
    var sortType: MeetingSortType { get }
    func selectSortType(for type: MeetingSortType)
}
