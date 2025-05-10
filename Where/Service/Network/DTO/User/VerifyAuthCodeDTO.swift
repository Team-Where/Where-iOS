//
//  VerifyAuthCodeDTO.swift
//  Where
//
//  Created by Swain Yun on 5/10/25.
//

import Foundation

enum VerifyAuthCodeDTO {
    struct Request: Encodable {
        let email: String
        let code: String
    }
}
