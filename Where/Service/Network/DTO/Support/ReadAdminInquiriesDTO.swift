//
//  ReadAdminInquiriesDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 1:1문의 조회 - 관리자
enum ReadAdminInquiriesDTO {
    struct Request: Encodable {
        let searchCriteria: UInt64
        
        enum CodingKeys: String, CodingKey {
            case searchCriteria = "type"
        }
    }
    
    typealias Response = [InquiryDetail]
}

extension ReadAdminInquiriesDTO {
    struct InquiryDetail: Decodable {
        let inquiryID: UInt64
        let userID: UInt64
        let userName: String
        let title: String
        let content: String
        let imageURLStrings: [String]?
        let isAnswered: Bool
        let answerContent: String?
        
        enum CodingKeys: String, CodingKey {
            case inquiryID = "id"
            case userID = "userId"
            case imageURLStrings = "images"
            case isAnswered = "answered"
            case userName, title, content, answerContent
        }
    }
}
