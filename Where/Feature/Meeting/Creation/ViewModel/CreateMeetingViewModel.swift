//
//  CreateMeetingViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/4/25.
//

import SwiftUI
import Combine

final class CreateMeetingViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var selectedImage: UIImage?
    @Published var tempMeetingInfo: TemporaryMeetingInfo?
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    
    init(
        communityCore: CommunityCoreProtocol,
        meetingCore: MeetingCoreProtocol
    ) {
        self.communityCore = communityCore
        self.meetingCore = meetingCore
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
        meetingCore.createMeeting(info: tempMeeting)
    }
}
