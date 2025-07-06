//
//  PlaceAddedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct PlaceAddedPayload {
    
    let meetingID: UInt64
    let placeID: UInt64
    let placeSharerImage: String
    let placeName: String
    let address: String
    let likeCount: UInt64
    let isPicked: Bool
    let naverLink: String
    let kakaoLink: String
}
