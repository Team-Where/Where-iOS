//
//  MeetingDetailFromLinkDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

enum MeetingDetailFromLinkDTO {
    /// 모임 초대 조회 RequestDTO
    struct Request: Encodable {
        let invitationCode: String
        
        enum CodingKeys: String, CodingKey {
            case invitationCode = "link"
        }
    }
    /// 모임 초대 조회 ResponseDTO
    struct Response: Decodable {
        let meetingID: UInt64
        let title: String
        let meetingImageURLString: String?
        let scheduleDate: String
        let scheduleTime: String
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "meetingId"
            case meetingImageURLString = "image"
            case title, scheduleDate, scheduleTime
        }
    }
}
