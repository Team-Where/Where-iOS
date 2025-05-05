//
//  MeetingDetailFromLinkDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

import Foundation

/// 모임 초대 조회 DTO
enum MeetingDetailFromLinkDTO {
    struct Response: Decodable {
        let meetingID: UInt64
        let title: String
        let meetingImageURLString: String?
        let scheduleDate: String?
        let scheduleTime: String?
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "meetingId"
            case meetingImageURLString = "image"
            case title, scheduleDate, scheduleTime
        }
        
        func toEntity() -> Meeting {
            return .init(
                id: meetingID,
                title: title,
                description: "",
                imageURL: URL(string: meetingImageURLString ?? ""),
                createdAt: .now,
                scheduleDate: scheduleDate?.toDate(by: .yyyyMMddHyphen),
                scheduleTime: scheduleTime?.toDate(by: .HHmmss),
                isFinished: false
            )
        }
    }
}
