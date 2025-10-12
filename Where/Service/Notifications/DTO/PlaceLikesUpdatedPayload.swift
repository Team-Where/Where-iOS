//
//  PlaceLikesUpdatedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceLikesUpdatedPayload: PayloadType {
    let placeID: UInt64
    let likesCount: UInt64
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        
        guard let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let likesCount = userInfo[UserInfoKey.likes.rawValue] as? UInt64
        else {
            return nil
        }
        self._base = basePayload
        self.placeID = placeID
        self.likesCount = likesCount
    }
}
