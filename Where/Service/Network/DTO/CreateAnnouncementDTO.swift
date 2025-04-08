//
//  CreateAnnouncementDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 공지 등록 DTO
enum CreateAnnouncementDTO {
    struct Request: Encodable {
        let title: String
        let content: String
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
