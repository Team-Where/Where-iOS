//
//  WhereFont.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import Foundation

enum WhereFont {
    case title24semibold, title20semibold
    case subtitle18bold, subtitle18semibold
    case body16semibold, body16medium, body16regular
    case body14semibold, body14medium, body14regular
    case caption12medium, caption12regular
    case caption11regular
    
    var pretendard: Pretendard {
        switch self {
        case .title24semibold, .title20semibold, .subtitle18semibold, .body16semibold, .body14semibold:
            return .semibold
        case .subtitle18bold:
            return .bold
        case .body16medium, .body14medium, .caption12medium:
            return .medium
        case .body16regular, .body14regular, .caption12regular, .caption11regular:
            return .regular
        }
    }
    
    var size: CGFloat {
        switch self {
        case .title24semibold:
            return 24
        case .title20semibold:
            return 20
        case .subtitle18bold, .subtitle18semibold:
            return 18
        case .body16semibold, .body16medium, .body16regular:
            return 16
        case .body14semibold, .body14medium, .body14regular:
            return 14
        case .caption12medium, .caption12regular:
            return 12
        case .caption11regular:
            return 11
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .title24semibold, .title20semibold, .subtitle18bold, .subtitle18semibold, .caption12medium, .caption12regular, .caption11regular:
            return size * 1.4
        case .body16semibold, .body16medium, .body16regular, .body14semibold, .body14medium, .body14regular:
            return size * 1.45
        }
    }
}
