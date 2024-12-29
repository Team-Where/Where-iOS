//
//  Font+Pretendard.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI

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
