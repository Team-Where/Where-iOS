//
//  CreateMeetingViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/4/25.
//

import Foundation
import Combine
import Swinject

final class CreateMeetingViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var selectedImage: Data?
    @Published var tempMeetingInfo: TemporaryMeetingInfo?
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
    }
}

// MARK: Interfaces
extension CreateMeetingViewModel {
    func initialize() {
        isPopupPresented = false
        selectedImage = nil
        tempMeetingInfo = nil
    }
    
    func createMeeting() {
        guard let tempMeeting = tempMeetingInfo else { return }
    }
}
