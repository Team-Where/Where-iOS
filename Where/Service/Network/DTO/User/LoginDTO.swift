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
}
