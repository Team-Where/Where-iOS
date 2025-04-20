//
//  UserCredential.swift
//  Where
//
//  Created by Swain Yun on 3/1/25.
//

import Foundation

struct UserCredential {
    let provider: AuthentificationProvider
    let ci: String
    let email: String
    let nickname: String
    
    init(
        provider: AuthentificationProvider,
        ci: String? = nil,
        email: String? = nil,
        nickname: String? = nil
    ) {
        self.provider = provider
        self.ci = ci ?? ""
        self.email = email ?? ""
        self.nickname = nickname ?? ""
    }
}
