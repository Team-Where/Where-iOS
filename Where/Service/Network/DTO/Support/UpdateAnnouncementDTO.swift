//
//  UpdateAnnouncementDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/9/25.
//

/// 공지 수정 DTO
enum UpdateAnnouncementDTO {
    struct Request: Encodable {
        let announcementID: UInt64
        let title: String?
        let content: String?
        
        enum CodingKeys: String, CodingKey {
            case announcementID = "id"
            case title, content
        }
    }
    
    struct Response: Decodable {
        let announcementID: UInt64
        let title: String
        let content: String
        
        enum CodingKeys: String, CodingKey {
            case announcementID = "id"
            case title, content
        }
    }
}
