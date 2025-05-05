//
//  AcceptInvitationViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import Foundation
import Combine
import Swinject

final class AcceptInvitationViewModel: ObservableObject {
    @Published var meeting: Meeting!
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.invitedMeeting
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: ErrorHanding
            } receiveValue: { [weak self] in
                self?.meeting = $0
            }
            .store(in: &cancellables)
    }
}

extension AcceptInvitationViewModel {
    // TODO: 화면 띄워지는 시점에서 초대 받은 모임 정보 불러오기 호출
    func onApear(_ invitedCode: String) {
        meetingCore.readMeetingDetailForInvitationLink(inviteCode: invitedCode)
    }
    // TODO: 유니버셜링크 연동 후, 초대 수락 구현
}
