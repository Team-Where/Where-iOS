//
//  Comment.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

struct Comment: Hashable {
    /// 장소 식별자
    let placeId: UInt64
    /// 코멘트 내용
    let description: String
    /// 코멘트 작성자의 식별자
    let writerId: UInt64
    /// 코멘트 작성일시
    let createdAt: Date
    /// 코멘트 수정일시
    let updatedAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(placeId)
        hasher.combine(description)
        hasher.combine(writerId)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
    }
}
