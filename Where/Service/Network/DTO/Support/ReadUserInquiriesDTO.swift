//
//  ReadUserInquiriesDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 1:1 문의 조회 - 일반 사용자
enum ReadUserInquiriesDTO {
    struct Request: Encodable {
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case userID = "id"
        }
    }
    typealias Response = [InquiryDetail]
}

extension ReadUserInquiriesDTO {
    struct InquiryDetail: Decodable {
        let inquiryID: UInt64
        let title: String
        let content: String
        let imageURLStrings: [String]?
        let isAnswered: Bool
        let answerContent: String?
        
        enum CodingKeys: String, CodingKey {
            case inquiryID = "id"
            case isAnswered = "answerd"
            case imageURLStrings = "images"
            case title, content, answerContent
        }
    }
    
}

