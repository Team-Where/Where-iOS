//
//  MeetingDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 생성 DTO
enum CreateMeetingDTO {
    struct Request: Encodable {
        let title: String
        let creatorID: UInt64
        let description: String
        let participants: [UInt64]?
        
        enum CodingKeys: String, CodingKey {
            case title, description, participants
            case creatorID = "fromId"
        }
    }
    
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
        
        func toEntity() -> Meeting {
            return .init(
                id: meetingID,
                title: title,
                description: description,
                createdAt: createdAt.toDate(by: .serverDateTimeWithMS) ?? .now,
                isFinished: false
            )
        }
    }
}
