//
//  CreateScheduleDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

enum CreateScheduleDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        let date: String
        let time: String
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case date, time
            case meetingID = "meetingId"
            case userID = "userId"
        }
    }
    
    struct Response: Decodable {
        let meetingID: UInt64
        let date: String
        let time: String
        
        enum CodingKeys: String, CodingKey {
            case date, time
            case meetingID = "meetingId"
        }
    }
}
