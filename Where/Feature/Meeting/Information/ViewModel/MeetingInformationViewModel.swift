//
//  MeetingInformationViewModel.swift
//  Where
//
//  Created by BOMBSGIE on 4/28/25.
//

import Foundation
import Swinject
import Combine

final class MeetingInformationViewModel: ObservableObject {
    @Published private var _meeting: Meeting!
    @Published private var meetingID: UInt64!
    
    @Published var sheetType: SheetType?
    @Published var titleText = String()
    @Published var descriptionText = String()
    @Published var editStep: EditStep = .entry
    
    @Published private(set) var isTitleUpdatingProcessing: Bool = false
    @Published private(set) var isDescriptionUpdatingProcessing: Bool = false
    @Published private(set) var isExitProcessing: Bool = false
    
    var titleUpdateButtonDisabled: Bool { isTitleUpdatingProcessing || titleText.isEmpty }
    var descriptionUpdateButtonDisabled: Bool { isDescriptionUpdatingProcessing }
    var exitButtonDisabled: Bool { isExitProcessing }
    
    var meeting: Meeting {
        _meeting
    }
    
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.meetings
            .combineLatest($meetingID)
            .compactMap{ (dict, id) -> Meeting? in
                guard let id else { return nil }
                return dict[id]
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] meeting in
                self?._meeting = meeting
                self?.titleText = meeting.title
                self?.descriptionText = meeting.description
            }
            .store(in: cancellableBag, key: "Meetings")
    }
}

extension MeetingInformationViewModel {
    func setMeeting(id: UInt64) {
        self.meetingID = id
    }
    
    func updateMeetingTitle() {
        isTitleUpdatingProcessing = true
        meetingCore.updateMeeting(
            id: meeting.id,
            title: titleText,
            description: nil,
            imageData: nil
        )
        .sink { [weak self] _ in
            self?.isTitleUpdatingProcessing = false
            self?.editStep = .entry
        } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
    
    func updateMeetingDescription() {
        isDescriptionUpdatingProcessing = true
        cancellableBag[#function] = meetingCore.updateMeeting(
            id: meeting.id,
            title: nil,
            description: descriptionText,
            imageData: nil
        )
        .sink { [weak self] completion in
            self?.isDescriptionUpdatingProcessing = false
            self?.editStep = .entry
        } receiveValue: { _ in }
    }
    
    func exitMeeting() {
        isExitProcessing = true
        cancellableBag[#function] = meetingCore.exitMeeting(id: meeting.id)
            .sink { [weak self] completion in
                self?.isExitProcessing = false
                self?.editStep = .entry
            } receiveValue: { _ in }
    }
}

// MARK: - Nested Type

extension MeetingInformationViewModel {
    /// 모임정보 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        /// 모임정보 편집
        case editMeetingInfo
        
        var id: String { String(describing: self) }
    }
    
    /// 시트 내부에서 모임정보 편집 간 단계
    enum EditStep {
        /// 모임명, 메모 표시 단계
        case entry
        /// 모임명 수정 단계
        case title
        /// 메모 수정 단계
        case memo
    }
}
