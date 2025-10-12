//
//  FCMRegisterDTO.swift
//  Where
//
//  Created by Swain Yun on 6/18/25.
//

import Foundation

enum FCMRegisterDTO {
    struct Request: Encodable {
        let fcmToken: String?
    }
}
