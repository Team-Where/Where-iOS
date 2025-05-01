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
        // TODO: API 응답 스펙 따라서 수정할 것
        let accessToken: String
        let refreshToken: String
    }
}
