//
//  LoginDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/15/25.
//

enum LoginDTO {
    struct Request: Encodable {
        // TODO: User ID 받아올 수 있도록 수정
        let email: String
        let password: String
        
        enum CodingKeys: String, CodingKey {
            case email = "username"
            case password = "password"
        }
    }
}
