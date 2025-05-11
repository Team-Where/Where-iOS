//
//  ContentViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import Foundation
import Combine
import Swinject

final class ContentViewModel: ObservableObject {
    @Published var selectedTab: TabItem = .myMeeting
    @Published var previousTab: TabItem = .myMeeting
    @Published var isCreateMeetingSheetPresented = false
    @Published var fullScreenCoverType: FullScreenCoverType?
    
    private var isLoginNeeded: Bool = true
    
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loginCompleted:
                    self?.fullScreenCoverType = nil
                    self?.isLoginNeeded = false
                    
                case .registrationNeeded:
                    self?.fullScreenCoverType = nil
                    self?.isLoginNeeded = true
                    
                case .loginNeeded:
                    self?.isLoginNeeded = true
                }
            }
            .store(in: cancellableBag, key: "AuthentificationState")
        
        meetingCore.createdMeeting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] meeting in
                self?.fullScreenCoverType = .completeCreation(meeting)
            }
            .store(in: cancellableBag, key: "CreatedMeeting")
    }
}

// MARK: Nested Types
extension ContentViewModel {
    /// 탭 뷰의 탭아이템 종류
    enum TabItem: Hashable {
        case myMeeting
        case createMeeting
        case friendsList
    }
    
    /// 메인(루트) 화면에서 라우팅 가능한 풀스크린커버의 종류
    enum FullScreenCoverType: Identifiable {
        /// 모임 생성 완료 화면
        case completeCreation(Meeting)
        /// 로그인 화면
        case login
        
        var id: String { String(describing: self) }
    }
}

// MARK: - Interfaces
extension ContentViewModel {
    func onChange(_ newTab: TabItem) {
        guard newTab == .createMeeting else {
            return previousTab = newTab
        }
        
        // 새 모임 만들기 탭이 선택 됐으면 로그인 필요한지 확인해야함
        guard isLoginNeeded == false else {
            // 비로그인 상황이라면 새 모임 만들기 진행 불가, 로그인 화면 등장
            return fullScreenCoverType = .login
        }
        
        // 로그인한 상황이라면 새 모임 만들기 진행 가능
        isCreateMeetingSheetPresented = true
        selectedTab = previousTab
    }
    
    func willFullScreenCoverDisappear() {
        selectedTab = previousTab
    }
}
