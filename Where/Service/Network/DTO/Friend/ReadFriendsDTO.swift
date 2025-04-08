//
//  ReadFriendsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 친구 목록 조회
enum ReadFriendsDTO {
    struct Request: Encodable {
        let id: UInt64
    }
    
    typealias Response = [Friend]
}

extension ReadFriendsDTO {
    struct Friend: Decodable {
        let id: UInt64
        let name: String
        let imageURLString: String?
        let isBookmarked: Bool
        let relatedMeetingDetails: [MeetingDetail]?
    }
}

extension ReadFriendsDTO.Friend {
    struct MeetingDetail: Decodable {
        let id: UInt64
        let imageURLString: String?
        let title: String
        let description: String
        let date: String
        
        enum CodingKeys: String, CodingKey {
            case description, date
            case id = "meetingId"
            case imageURLString = "meetingImage"
            case title = "meetingName"
        }
    }
}
