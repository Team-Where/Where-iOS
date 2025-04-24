//
//  ReadAnnouncementsDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

import Foundation

/// 공지 조회 DTO
enum ReadAnnouncementsDTO {
    typealias Response = [AnnouncementDetail]
}

extension ReadAnnouncementsDTO {
    struct AnnouncementDetail: Decodable {
        let announcementID: UInt64
        let title: String
        let content: String
        let modifiedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case announcementID = "id"
            case title, content
            case modifiedAt = "date"
        }
    }
}
