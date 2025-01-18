//
//  Place.swift
//  Where
//
//  Created by Swain Yun on 1/10/25.
//

import Foundation

/// 모임 장소
struct Place: Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let imageURL: URL?
    let address: String
    let comments: [String]
    let likes: Int
    let isPicked: Bool
    
    init(
        name: String = "장소명",
        imageURL: URL? = nil,
        address: String = "도로명주소",
        comments: [String] = ["웨이팅 길다"],
        likes: Int = 1,
        isPicked: Bool = true
    ) {
        self.name = name
        self.imageURL = imageURL
        self.address = address
        self.comments = comments
        self.likes = likes
        self.isPicked = isPicked
    }
}
