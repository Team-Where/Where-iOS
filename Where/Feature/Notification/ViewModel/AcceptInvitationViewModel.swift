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
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        
    }
}

// MARK: - Interfaces
extension AcceptInvitationViewModel {
    func acceptInvitation() {
        // TODO: 초대수락 기능 연결
    }
}
