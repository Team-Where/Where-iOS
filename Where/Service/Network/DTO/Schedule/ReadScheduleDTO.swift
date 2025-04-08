//
//  ReadScheduleDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

enum ReadScheduleDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "meetingId"
        }
    }
    
    struct Response: Decodable {
        let date: String
        let time: String
    }
}
