//
//  NotificationListViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/29/25.
//

import Foundation
import Swinject
import Combine

@Observable
final class NotificationListViewModel {
    private(set) var pendingMeetings = [PendingMeeting]()
    
    private let meetingCore: MeetingCoreProtocol
    private var cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
    }
}


extension NotificationListViewModel {
    func onAppear() {
        meetingCore.readPendingMeetingInvitation()
            .subscribe(on: DispatchQueue.main)
            .sink { completions in
                //TODO: Error Handling
            } receiveValue: { [weak self] in
                self?.pendingMeetings = $0
            }
            .store(in: cancellableBag, key: "readPendingMeetings")
    }
}
