//
//  UpdateMeetingDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 수정 DTO
enum UpdateMeetingDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        let title: String?
        let description: String?
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case title, description
            case meetingID = "id"
            case userID = "userId"
        }
    }
    
    struct Response: Decodable {
        let meetingID: UInt64
        let title: String
        let description: String
        let invitationLink: String
        let imageURLString: String?
        
        enum CodingKeys: String, CodingKey {
            case title, description
            case meetingID = "id"
            case invitationLink = "link"
            case imageURLString = "image"
        }
    }
}
