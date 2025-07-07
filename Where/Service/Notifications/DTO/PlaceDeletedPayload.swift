//
//  PlaceDeletedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceDeletedPayload: PayloadType {
    let id: UInt64
    let title: String
    let content: String
    let type: NotificationType
    
    let placeID: UInt64
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basicPayload = BasicPayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let placeID = userInfo["id"] as? UInt64 else { return nil }
        
        self.id = basicPayload.id
        self.title = basicPayload.title
        self.content = basicPayload.content
        self.type = basicPayload.type
        
        self.placeID = placeID
    }
}
