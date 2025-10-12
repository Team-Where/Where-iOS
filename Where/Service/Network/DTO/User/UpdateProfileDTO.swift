//
//  UpdateProfileDTO.swift
//  Where
//
//  Created by Swain Yun on 5/4/25.
//

import Foundation

enum UpdateProfileDTO {
    struct Response: Decodable {
        let profileImageURL: URL?
        
        enum CodingKeys: String, CodingKey {
            case profileImageURL = "newLink"
        }
    }
}
