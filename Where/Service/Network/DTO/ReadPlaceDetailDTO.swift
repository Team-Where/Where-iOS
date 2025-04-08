//
//  ReadPlaceDetailDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

enum ReadPlaceDetailDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "meetingId"
            case userID = "userId"
        }
    }
    
    typealias Response = [Place]
}

extension ReadPlaceDetailDTO {
    struct Place: Decodable {
        let id: UInt64
        let meetingID: UInt64
        let naverLinkString: String
        let kakaoLinkString: String
        let name: String
        let address: String
        let likingUserIDs: [UInt64]
        let pickedState: String
        let isSimulaneouslyPicked: Bool
        
        enum CodingKeys: String, CodingKey {
            case id, name, address
            case meetingID = "meetingId"
            case naverLinkString = "naverLink"
            case kakaoLinkString = "kakaoLink"
            case likingUserIDs = "likes"
            case pickedState = "placeStatus"
            case isSimulaneouslyPicked = "together"
        }
    }
}
