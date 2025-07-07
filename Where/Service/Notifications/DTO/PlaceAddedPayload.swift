//
//  PlaceAddedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceAddedPayload: PayloadType {
    let id: UInt64
    let title: String
    let content: String
    let type: NotificationType
    
    let meetingID: UInt64
    let placeID: UInt64
    let placeSharerImage: String?
    let placeName: String
    let address: String
    let likeCount: UInt64
    let isPicked: Bool
    let naverLink: String
    let kakaoLink: String
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basicPayload = BasicPayload(userInfo: userInfo)
        else {
            return nil
        }
        
        guard let meetingID = userInfo[UserInfoKey.meetingId.rawValue] as? UInt64,
              let placeID = userInfo[UserInfoKey.placeId.rawValue] as? UInt64,
              let placeName = userInfo[UserInfoKey.placeName.rawValue] as? String,
              let address = userInfo[UserInfoKey.address.rawValue] as? String,
              let likeCount = userInfo[UserInfoKey.likes.rawValue] as? UInt64,
              let isPicked = userInfo[UserInfoKey.placeStatus.rawValue] as? String,
              let naverLink = userInfo["naverLink"] as? String,
              let kakaoLink = userInfo["kakaoLink"] as? String
        else {
            return nil
        }
        
        self.id = basicPayload.id
        self.title = basicPayload.title
        self.content = basicPayload.content
        self.type = basicPayload.type
        
        self.meetingID = meetingID
        self.placeID = placeID
        self.placeSharerImage = userInfo[UserInfoKey.user.rawValue] as? String
        self.placeName = placeName
        self.address = address
        self.likeCount = likeCount
        self.isPicked = isPicked == "Picked"
        self.naverLink = naverLink
        self.kakaoLink = kakaoLink
    }
}
