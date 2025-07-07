//
//  PayloadType.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

protocol PayloadType {
    var _base: BasePayload { get }
    
    init?(userInfo: [AnyHashable : Any])
}

extension PayloadType {
    var id: UInt64 {
        _base.id
    }
    var title: String {
        _base.title
    }
    
    var content: String {
        _base.content
    }
    
    var type: NotificationType {
        _base.type
    }
}

struct BasePayload {
    let id: UInt64
    let title: String
    let content: String
    let type: NotificationType
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let id = userInfo["gcm.message_id"] as? UInt64
        else { return nil }
        
        guard let aps   = userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any],
              let title = alert["title"] as? String,
              let body  = alert["body"] as? String
        else {
            return nil
        }
        
        guard let code = userInfo["code"] as? Int,
              let type = NotificationType(rawValue: code)
        else {
            return nil
        }
        self.id = id
        self.title = title
        self.content = body
        self.type = type
    }
}

/// userInfo에서 꺼내올 키 값들의 열거형
/// - rawValue로 접근해서 사용
enum UserInfoKey: String {
    case id
    /// 모임 식별자 키
    case meetingId
    /// 장소 식별자 키
    case placeId
    /// 장소 공유한 유저 프로필 이미지 링크 키
    case user
    /// 장소 이름 키
    case placeName
    /// 장소 주소 키
    case address
    /// 좋아요 수 키
    case likes
    /// 장소 선택 여부 키
    case placeStatus
    /// 같이 찾은 장소 여부 키
    case together
}
