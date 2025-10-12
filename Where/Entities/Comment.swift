//
//  Comment.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

struct Comment: Hashable {
    /// 고유 식별자
    let id: UInt64
    /// 장소 식별자
    let placeId: UInt64
    /// 코멘트 내용
    let description: String
    /// 로그인한 사용자가 작성한 코멘트인지
    let isMyComment: Bool
    /// 코멘트 생성 시각
    let createdAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(placeId)
        hasher.combine(description)
        hasher.combine(isMyComment)
    }
}
