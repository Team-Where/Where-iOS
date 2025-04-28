//
//  MeetingInformationViewModel.swift
//  Where
//
//  Created by BOMBSGIE on 4/28/25.
//

import Foundation

final class MeetingInformationViewModel: ObservableObject {
    @Published var sheetType: SheetType?
    @Published private var _meeting: Meeting!
    
    var meeting: Meeting {
        _meeting
    }
}

extension MeetingInformationViewModel {
    func setMeeting(_ meeting: Meeting) {
        _meeting = meeting
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
}
