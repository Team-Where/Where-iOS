//
//  SideMenuContentViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class SideMenuContentViewModel {
    private(set) var user: User?
    private(set) var totalMeetingsCount = Int.zero
    
    var isLoginNeeded: Bool { user == nil }
    
    private let authCore: AuthentificationCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: cancellableBag, key: "CurrentUser")
        
        meetingCore.meetings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.totalMeetingsCount = dict.values.count
            }
            .store(in: cancellableBag, key: "Meetings")
    }
}
