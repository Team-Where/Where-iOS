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
    @Published var sheetType: SheetType?
    @Published var titleText = String()
    @Published var descriptionText = String()
    @Published var editStep: EditStep = .entry
    @Published var isExit = false
    
    @Published private(set) var isTitleUpdatingProcessing: Bool = false
    @Published private(set) var isDescriptionUpdatingProcessing: Bool = false
    @Published private(set) var isExitProcessing: Bool = false
    
    var titleUpdateButtonDisabled: Bool { isTitleUpdatingProcessing || titleText.isEmpty }
    var descriptionUpdateButtonDisabled: Bool { isDescriptionUpdatingProcessing }
    var exitButtonDisabled: Bool { isExitProcessing }
    
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        
    }
}

extension MeetingInformationViewModel {
    func setMeeting(_ meeting: Meeting) {
        titleText = meeting.title
        descriptionText = meeting.description
    }
    
    func updateMeetingTitle(by id: UInt64) {
        isTitleUpdatingProcessing = true
        meetingCore.updateMeeting(
            id: id,
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
    
    func updateMeetingDescription(by id: UInt64) {
        isDescriptionUpdatingProcessing = true
        cancellableBag[#function] = meetingCore.updateMeeting(
            id: id,
            title: nil,
            description: descriptionText,
            imageData: nil
        )
        .sink { [weak self] completion in
            self?.isDescriptionUpdatingProcessing = false
            self?.editStep = .entry
        } receiveValue: { _ in }
    }
    
    func exitMeeting(by id: UInt64) {
        isExitProcessing = true
        meetingCore.exitMeeting(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    self?.isExitProcessing = false
                    self?.sheetType = nil
                    self?.editStep = .entry
                    self?.isExit = true
                case .failure(let error):
                    self?.isExitProcessing = false
                    #if DEBUG
                    print("ExitMeeting Error: \(error)")
                    #endif
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
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
