//
//  Font.swift
//  Where
//
//  Created by Swain Yun on 5/12/25.
//

import SwiftUI

// MARK: - Font+Pretendard
extension Font {
    static func pretendard(_ type: Pretendard, size: CGFloat) -> Font {
        .custom(type.rawValue, size: size)
    }
    
    static func `where`(_ whereFont: WhereFont, size: CGFloat? = nil) -> Font {
        let name = whereFont.pretendard.rawValue
        let size = size ?? whereFont.size
        return .custom(name, size: size)
    }
}
