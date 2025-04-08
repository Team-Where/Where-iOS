//
//  MeetingDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

enum CreateMeetingDTO {
    /// 모임 생성 RequestDTO
    struct Request: Encodable {
        let title: String
        let creatorID: String
        let description: String
        let participants: [UInt64]?
        
        enum CodingKeys: String, CodingKey {
            case title, description, participants
            case creatorID = "fromId"
        }
    }
    
    /// 모임 생성 ResponseDTO
    struct Response: Decodable {
        let meetingID: UInt64
        let title: String
        let description: String
        let sharedLink: String
        let imageURLString: String?
        let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case title, description, createdAt
            case meetingID = "id"
            case sharedLink = "link"
            case imageURLString = "image"
        }
    }
}
