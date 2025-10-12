//
//  RegisterDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/15/25.
//

import Foundation

/// 회원가입DTO
///
/// - Note:
///     'nickname' 프로퍼티에 대한 CodingKey를 'nickName'으로 해두어도 인코딩 실패로 인한 400 코드 응답이 발생.
///     'nickName' 으로 프로퍼티명 수정 후 시도, 200 코드 응답 확인
///     CodingKey 설정해두어도 키가 'nickname'으로 인코딩 되는 원인을 모르겠음.
///     차후 수정 가능
enum RegisterDTO {
    struct Request: Encodable {
        let email: String
        let password: String
        let nickName: String
        
//        enum CondingKeys: String, CodingKey {
//            case email, password
//            case nickname = "nickName"
//        }
    }
    
    struct Response: Decodable {
        let id: UInt64
        let email: String
        let nickname: String
        let profileImageURLString: String?
        let isNicknameDuplicated: Bool
        
        enum CodingKeys: String, CodingKey {
            case id, email
            case nickname = "nickName"
            case profileImageURLString = "profileImage"
            case isNicknameDuplicated = "existsByNickName"
        }
        
        func toEntity() -> User {
            .init(
                id: id,
                nickname: nickname,
                createdAt: .now,
                imageURL: URL(string: profileImageURLString ?? "")
            )
        }
    }
}
