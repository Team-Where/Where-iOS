//
//  User.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import Foundation

/// 사용자 정보
struct User: Identifiable {
    let id: UUID = UUID()
    let imageURL: URL? = nil
    let nickname: String
    let isFavorite: Bool
}
