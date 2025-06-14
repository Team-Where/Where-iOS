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
    private(set) var processingState: ProcessingState = .waiting
    private(set) var isLoginNeeded: Bool = false
    
    private let authCore: AuthentificationCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .sink { [weak self] user in
                self?.isLoginNeeded = user == nil
            }
            .store(in: cancellableBag, key: "CurrentUser")
    }
}

// MARK: - Nested Types
extension AcceptInvitationViewModel {
    enum ProcessingState {
        case waiting
        case processing
    }
}

// MARK: - Interfaces
extension AcceptInvitationViewModel {
    func acceptInvitation(meetingID: UInt64, _ handler: @escaping (Bool) -> Void) {
        processingState = .processing
        meetingCore.acceptInvitationByLinkCode()
            .sink { [weak self] completion in
                self?.processingState = .waiting
                
                switch completion {
                case .finished: handler(true)
                case .failure: handler(false)
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}
