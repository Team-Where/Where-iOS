//
//  PlaceSimultaneouslyPickedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceSimultaneouslyPickedPayload: PayloadType {
    let placeID: UInt64
    let isSimultaneouslyPicked: Bool
    let placeSharerImage: String?
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayloadType = BasePayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let isSimultaneouslyPicked = userInfo[UserInfoKey.together.rawValue] as? Bool,
              let placeSharerImage = userInfo[UserInfoKey.user.rawValue] as? String
        else {
            return nil
        }
        
        _base = basePayloadType
        
        self.placeID = placeID
        self.isSimultaneouslyPicked = isSimultaneouslyPicked
        self.placeSharerImage = placeSharerImage
    }
}
