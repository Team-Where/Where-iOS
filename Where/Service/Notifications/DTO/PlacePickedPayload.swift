//
//  PlacePickedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlacePickedPayload {
    let placeID: UInt64
    let isPicked: Bool
    
    private let basePayload: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        
        guard let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let isPicked = userInfo[UserInfoKey.placeStatus.rawValue] as? String
        else {
            return nil
        }
        self.basePayload = basePayload
        self.placeID = placeID
        self.isPicked = isPicked == "Picked"
    }
}

extension PlacePickedPayload:  PayloadType {
    var id: UInt64 {
        basePayload.id
    }
    
    var title: String {
        basePayload.title
    }
    
    var content: String {
        basePayload.content
    }
    
    var type: NotificationType {
        basePayload.type
    }
}
