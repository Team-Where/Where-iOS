//
//  PlacePickedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlacePickedPayload: PayloadType {
    let placeID: UInt64
    let isPicked: Bool
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        
        guard let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let isPicked = userInfo[UserInfoKey.placeStatus.rawValue] as? String
        else {
            return nil
        }
        self._base = basePayload
        self.placeID = placeID
        self.isPicked = isPicked == "Picked"
    }
}
