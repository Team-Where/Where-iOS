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
        let likesCount: Int
        let result: Bool
        let pickedState: String
        let isSimulaneouslyShared: Bool
        let pickedUserImageURLStrings: [String]?
        
        enum CodingKeys: String, CodingKey {
            case id, name, address
            case meetingID = "meetingId"
            case naverLinkString = "naverLink"
            case kakaoLinkString = "kakaoLink"
            case likesCount = "likes"
            case result = "myLike"
            case pickedState = "placeStatus"
            case isSimulaneouslyShared = "together"
            case pickedUserImageURLStrings = "users"
        }
        
        func toEntity() -> Place {
            .init(
                id: id,
                meetingId: meetingID,
                name: name,
                address: address,
                likesCount: likesCount,
                isLikedByMe: result,
                sharedUserImageURLs: (pickedUserImageURLStrings ?? []).compactMap { URL(string: $0) },
                pickedState: PickedState(pickedState),
                links: .init(naverLink: URL(string: naverLinkString), kakaoLink: URL(string: kakaoLinkString)),
                isSimulaneouslyShared: isSimulaneouslyShared
            )
        }
    }
}
