//
//  CommentAddedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct CommentAddedPayload: PayloadType {
    let placeID: UInt64
    let commentID: UInt64
    let description: String
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        guard let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let commentID = userInfo[UserInfoKey.commentId.rawValue] as? UInt64,
              let description = userInfo[UserInfoKey.description.rawValue] as? String
        else {
            return nil
        }
        
        self.placeID = placeID
        self.commentID = commentID
        self.description = description
        self._base = basePayload
    }
}
