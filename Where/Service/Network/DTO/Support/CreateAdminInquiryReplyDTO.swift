//
//  CreateAdminInquiryReplyDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 1:1 답변등록 - 관리자
enum CreateAdminInquiryReplyDTO {
    struct Request: Encodable {
        let inquiryID: UInt64
        let answerContent: String?
        
        enum CodingKeys: String, CodingKey {
            case inquiryID = "id"
            case answerContent
        }
    }
    
    struct Response: Decodable {
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
            case imageURLStrings = "iamges"
            case isAnswered = "answered"
            case userName, title, content,answerContent
        }
    }
}
