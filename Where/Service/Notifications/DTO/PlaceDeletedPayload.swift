//
//  PlaceDeletedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceDeletedPayload{
    let placeID: UInt64
    
    private let basePayload: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let placeID = userInfo[UserInfoKey.id.rawValue] as? UInt64 else { return nil }
        
        self.basePayload = basePayload
        self.placeID = placeID
    }
}

extension PlaceDeletedPayload: PayloadType {
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
