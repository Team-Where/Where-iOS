//
//  RegisterDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/15/25.
//

/// 회원가입DTO
enum RegisterDTO {
    struct Request: Encodable {
        let email: String
        let password: String
        let name: String
        let profileImage: String?
    }
    
    struct Response: Decodable {
        let statusCode: UInt64
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case statusCode = "status"
            case message
        }
    }
}
