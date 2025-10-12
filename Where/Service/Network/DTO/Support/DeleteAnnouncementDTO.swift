//
//  DeleteAnnouncementDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/9/25.
//

/// 공지 삭제
enum DeleteAnnouncementDTO {
    struct Request: Encodable {
        let announcementID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case announcementID = "id"
        }
    }
}
