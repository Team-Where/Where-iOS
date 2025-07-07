//
//  CommentUpdatedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct CommentUpdatedPayload: PayloadType {
    let commentID: UInt64
    let description: String
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        guard let commentID = userInfo[UserInfoKey.commentId.rawValue] as? UInt64,
              let description = userInfo[UserInfoKey.description.rawValue] as? String
        else {
            return nil
        }
        
        self.commentID = commentID
        self.description = description
        self._base = basePayload
    }
}
