//
//  LoginDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/15/25.
//

enum LoginDTO {
    struct Request: Encodable {
        let email: String
        let password: String
        
        enum CodingKeys: String, CodingKey {
            case email = "username"
            case password = "password"
        }
    }
    
    struct Response: Decodable {
        let isSuccess: Bool
        let message: String
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case message
            case isSuccess = "success"
            case userID = "userId"
        }
    }
}
