//
//  CheckEmailDuplicationDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/15/25.
//

/// E-mail 중복확인 DTO
enum CheckEmailDuplicationDTO {
    struct Request: Encodable {
        let email: String
    }
}
