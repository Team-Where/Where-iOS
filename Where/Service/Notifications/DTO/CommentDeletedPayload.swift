//
//  CommentDeletedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct CommentDeletedPayload: PayloadType {
    let commentID: UInt64
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        guard let commentID = userInfo[UserInfoKey.commentId.rawValue] as? UInt64
        else {
            return nil
        }
        
        self.commentID = commentID
        self._base = basePayload
    }
}
