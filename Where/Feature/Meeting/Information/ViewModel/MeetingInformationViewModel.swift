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
    
    @Published var sheetType: SheetType?
    @Published var titleText = String()
    @Published var descriptionText = String()
    @Published var editStep: EditStep = .entry
    
    var meeting: Meeting {
        _meeting
    }
    
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    init(resolver: Resolver) {
        meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
    }
    
    
    private func subscribe() {
        meetingCore.meetings
            .mapError {
                ViewModelError.meetingError($0)
            }
            .combineLatest($_meeting.setFailureType(to: ViewModelError.self))
            .compactMap{ (dict, meeting) -> Meeting? in
                guard let meeting else { return nil }
                return dict[meeting.id]
            }
            .sink { completion in
                // TODO: Error handling
            } receiveValue: { [weak self] in
                self?._meeting = $0
                self?.titleText = $0.title
                self?.descriptionText = $0.description
            }
            .store(in: &cancellables)
    }
}

extension MeetingInformationViewModel {
    func setMeeting(_ meeting: Meeting) {
        self._meeting = meeting
    }
    
    func updateMeeting() {
        meetingCore.updateMeeting(id: meeting.id, title: titleText, description: descriptionText, imageData: nil)
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
