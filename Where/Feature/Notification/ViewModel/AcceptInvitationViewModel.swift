//
//  AcceptInvitationViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class AcceptInvitationViewModel {
    private(set) var inviterName: String?
    private(set) var meeting: Meeting?
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.invitedMeeting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.meeting = $0
            }
            .store(in: cancellableBag, key: "InvitedMeeting")
    }
}

// MARK: - Interfaces
extension AcceptInvitationViewModel {
    func acceptInvitation() {
        // TODO: 초대수락 기능 연결
    }
}
