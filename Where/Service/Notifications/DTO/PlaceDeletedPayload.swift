//
//  PlaceDeletedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceDeletedPayload: PayloadType {
    let placeID: UInt64
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let placeID = userInfo[UserInfoKey.id.rawValue] as? UInt64 else { return nil }
        
        self._base = basePayload
        self.placeID = placeID
    }
}
