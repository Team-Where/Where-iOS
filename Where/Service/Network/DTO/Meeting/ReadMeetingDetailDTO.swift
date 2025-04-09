//
//  ReadMeetingDetailDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 정보 조회 DTO
enum ReadMeetingDetailDTO {
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
