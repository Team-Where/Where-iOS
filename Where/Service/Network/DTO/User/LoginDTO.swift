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
    }
    
    struct Response: Decodable {
        let accessToken: String
        let refreshToken: String
    }
}
