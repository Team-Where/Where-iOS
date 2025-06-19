//
//  CreatePlace.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 장소 생성
enum CreatePlaceDTO {
    /// 카카오맵으로부터 장소정보를 공유받아서 추가할 때 사용합니다.
    struct RequestForKakaomap: Encodable {
        let meetingID: UInt64
        let userID: UInt64
        let name: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case name, url
            case meetingID = "meetingId"
            case userID = "userId"
        }
    }
    
    /// 네이버지도로부터 장소정보를 공유받아서 추가할 때 사용합니다.
    struct RequestForNavermap: Encodable {
        let meetingID: UInt64
        let userID: UInt64
        let name: String
        let address: String
        
        enum CodingKeys: String, CodingKey {
            case name, address
            case meetingID = "meetingId"
            case userID = "userId"
        }
    }
    
    struct Response: Decodable {
        let placeID: UInt64
        let meetingID: UInt64
        let naverLinkString: String
        let kakaoLinkString: String
        let name: String
        let address: String
        let likesCount: Int
        let isLikedByMe: Bool
        let pickedState: String
        let isSimulaneouslyShared: Bool
        
        enum CodingKeys: String, CodingKey {
            case name, address
            case placeID = "id"
            case meetingID = "meetingId"
            case naverLinkString = "naverLink"
            case kakaoLinkString = "kakaoLink"
            case likesCount = "likes"
            case isLikedByMe = "myLike"
            case pickedState = "placeStatus"
            case isSimulaneouslyShared = "together"
        }
        
        func toEntity() -> Place {
            .init(
                id: placeID,
                meetingId: meetingID,
                name: name,
                address: address,
                likesCount: likesCount,
                commentsCount: .zero,
                isLikedByMe: isLikedByMe,
                sharedUserImageURLs: [],
                pickedState: PickedState(pickedState),
                links: .init(naverLink: URL(string: naverLinkString), kakaoLink: URL(string: kakaoLinkString)),
                isSimulaneouslyShared: isSimulaneouslyShared
            )
        }
    }
}
