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
    /// 모임을 생성한 사용자의 식별자
    let creatorId: UInt64
    /// 초대받는 인원들의 식별자
    let participants: [UInt64]
    /// 모임 대표 이미지
    let image: UIImage?
    
    static func initialize(_ userId: UInt64) -> Self {
        TemporaryMeetingInfo(title: String(), description: String(), creatorId: userId, participants: [], image: nil)
    }
    
    func setBasicInfo(title: String, description: String, image: UIImage?) -> Self {
        TemporaryMeetingInfo(title: title, description: description, creatorId: self.creatorId, participants: self.participants, image: image)
    }
    
    func setInvitedFriends(_ participants: [UInt64]) -> Self {
        TemporaryMeetingInfo(title: self.title, description: self.description, creatorId: self.creatorId, participants: participants, image: self.image)
    }
}
