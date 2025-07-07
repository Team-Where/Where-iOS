//
//  PayloadType.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

protocol PayloadType {
    var id: UInt64 { get }
    var title: String { get }
    var content: String { get }
    var type: NotificationType { get }
    
    init?(userInfo: [AnyHashable : Any])
}


struct BasicPayload: PayloadType {
    let id: UInt64
    let title: String
    let content: String
    let type: NotificationType
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let id = userInfo["gcm.message_id"] as? UInt64
        else { return nil }
        
        guard let aps   = userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any],
              let title = alert["title"] as? String,
              let body  = alert["body"] as? String
        else {
            return nil
        }
        
        guard let code = userInfo["code"] as? Int,
              let type = NotificationType(rawValue: code)
        else {
            return nil
        }
        self.id = id
        self.title = title
        self.content = body
        self.type = type
    }
}
