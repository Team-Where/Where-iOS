//
//  InvitationType.swift
//  Where
//
//  Created by Swain Yun on 8/13/25.
//

import Foundation

enum InvitationType {
    case inApp(id: UInt64)
    case linkCode(code: String, userID: UInt64)
}
