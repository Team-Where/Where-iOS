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
    /// 사용자 닉네임
    let nickname: String
    /// SMS 토큰
    let smsVerificationToken: String?
    /// 사용자 계정 생성일시(가입일시)
    let createdAt: Date
    /// 사용자 대표 이미지 URL
    let imageURL: URL?
    
    init(
        id: UInt64 = 0,
        nickname: String = "별명",
        smsVerificationToken: String? = nil,
        createdAt: Date = .now,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.nickname = nickname
        self.smsVerificationToken = smsVerificationToken
        self.createdAt = createdAt
        self.imageURL = imageURL
    }
}

/// 사용자 친구 관계
struct FriendRelationship: Identifiable {
    /// 고유 식별자
    let id: UInt64
    /// 친구 닉네임
    let nickname: String
    /// 친구 대표 이미지 URL
    let imageURL: URL?
    /// 즐겨찾기 여부
    let isFavorite: Bool
    
    init(
        id: UInt64,
        nickname: String,
        imageURL: URL? = nil,
        isFavorite: Bool
    ) {
        self.id = id
        self.nickname = nickname
        self.imageURL = imageURL
        self.isFavorite = isFavorite
    }
}
