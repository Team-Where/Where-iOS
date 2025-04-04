//
//  CreateMeetingSheetViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/4/25.
//

import SwiftUI
import Combine

final class CreateMeetingSheetViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var selectedImage: UIImage?
    @Published var tempMeetingInfo: TemporaryMeetingInfo?
    
    private let community: CommunityCoreProtocol
    
    init(community: CommunityCoreProtocol) {
        self.community = community
    }
}

// MARK: Interfaces
extension CreateMeetingSheetViewModel {
    func initialize() {
        isPopupPresented = false
        selectedImage = nil
        tempMeetingInfo = nil
    }
    
    func createMeeting() {
        guard let tempMeeting = tempMeetingInfo else { return }
        community.createMeeting(info: tempMeeting)
    }
}
