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
    /// 코멘트 작성자의 식별자
//    let writerId: UInt64
    /// 코멘트 생성 시각
    let createdAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(placeId)
        hasher.combine(description)
//        hasher.combine(writerId)
    }
}
