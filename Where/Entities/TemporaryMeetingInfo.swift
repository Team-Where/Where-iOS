//
//  TemporaryMeetingInfo.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import UIKit

/// 임시 모임 정보
struct TemporaryMeetingInfo {
    /// 모임 제목
    let title: String
    /// 모임 설명
    let description: String
    /// 초대받는 인원들의 식별자
    let participants: Set<UInt64>
    /// 모임 대표 이미지
    let imageData: Data?
    
    private init(
        title: String,
        description: String,
        participants: Set<UInt64>,
        imageData: Data?
    ) {
        self.title = title
        self.description = description
        self.participants = participants
        self.imageData = imageData
    }
    
    static func initialize() -> Self {
        TemporaryMeetingInfo(title: String(), description: String(), participants: [], imageData: nil)
    }
    
    func setBasicInfo(title: String, description: String, image: Data?) -> Self {
        TemporaryMeetingInfo(title: title, description: description, participants: self.participants, imageData: image)
    }
    
    func setInvitedFriends(_ participants: Set<UInt64>) -> Self {
        TemporaryMeetingInfo(title: self.title, description: self.description, participants: participants, imageData: self.imageData)
    }
}
