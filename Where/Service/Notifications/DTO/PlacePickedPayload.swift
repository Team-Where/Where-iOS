//
//  PlacePickedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlacePickedPayload: PayloadType {
    let id: UInt64
    let title: String
    let content: String
    let type: NotificationType
    
    let placeID: UInt64
    let isPicked: Bool
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basicPayload = BasicPayload(userInfo: userInfo) else { return nil }
        
        guard let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let isPicked = userInfo[UserInfoKey.placeStatus.rawValue] as? String
        else {
            return nil
        }
        
        self.id = basicPayload.id
        self.title = basicPayload.title
        self.content = basicPayload.content
        self.type = basicPayload.type
        
        self.placeID = placeID
        self.isPicked = isPicked == "Picked"
    }
}
