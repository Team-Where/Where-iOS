//
//  ReadPlaceDetailDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 장소 조회
enum ReadPlaceDetailDTO {
    typealias Response = [PlaceDetail]
}

extension ReadPlaceDetailDTO {
    struct PlaceDetail: Decodable {
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
        
        func toEntity() -> Place {
            .init(
                id: id,
                meetingId: meetingID,
                name: name,
                address: address,
                likesCount: likingUserIDs.count,
                pickedState: .init(pickedState),
                links: .init(naverLink: URL(string: naverLinkString), kakaoLink: URL(string: kakaoLinkString)),
                isSimulaneouslyPicked: isSimulaneouslyPicked
            )
        }
    }
}
