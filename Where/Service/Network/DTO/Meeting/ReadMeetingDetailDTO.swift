//
//  ReadMeetingDetailDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

enum ReadMeetingDetailDTO {
    /// 모임 정보 조회 RequestDTO
    struct Request: Encodable {
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case userID = "id"
        }
    }
    
    /// 모임 정보 조회 ResponseDTO
    typealias Response = [MeetingInfo]
}

extension ReadMeetingDetailDTO {
    struct MeetingInfo: Decodable {
        let meetingID: UInt64
        let title: String
        let description: String
        let invitationLink: String
        let meetingImageURLString: String?
        let isMeetingEnded: Bool
        let createdAt: String
        let scheduleDate: String?
        let scheduleTime: String?
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "id"
            case invitationLink = "link"
            case meetingImageURLString = "image"
            case isMeetingEnded = "finished"
            case title, description, createdAt, scheduleDate, scheduleTime
        }
    }
}
