//
//  User.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import Foundation

/// 사용자 정보
struct User: Identifiable {
    /// 고유 식별자
    let id: UInt64
    /// 사용자 이름
    let name: String
    /// 사용자 닉네임
    let nickname: String
    /// SMS 토큰
    let smsVerificationToken: String?
    /// 사용자 계정 생성일시(가입일시)
    let createdAt: Date
    /// 사용자 대표 이미지 URL
    let imageURL: URL?
    
    init(
        id: UInt64 = 1,
        name: String = "사용자",
        nickname: String = "별명",
        smsVerificationToken: String? = nil,
        createdAt: Date = .now,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.smsVerificationToken = smsVerificationToken
        self.createdAt = createdAt
        self.imageURL = imageURL
    }
}

// TODO: 도메인 모델 설계 중 (WIP)
/// 사용자 친구 관계
struct FriendRelationship {
    
}
