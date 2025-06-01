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
    private(set) var createdMeeting: Meeting?
    
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
                case .loginCompleted:
                    break
                }
            }
            .store(in: cancellableBag, key: "AuthentificationState")
        
        meetingCore.createdMeeting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] meeting in
                self?.createdMeeting = meeting
            }
            .store(in: cancellableBag, key: "CreatedMeeting")
    }
}

// MARK: - Interfaces
extension ContentViewModel {
    
}
