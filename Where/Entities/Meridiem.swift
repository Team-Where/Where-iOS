//
//  Meridiem.swift
//  Where
//
//  Created by Swain Yun on 1/9/25.
//

import Foundation

enum Meridiem: CaseIterable, Hashable, CustomStringConvertible {
    case am, pm
    
    var description: String {
        switch self {
        case .am:
            "오전"
        case .pm:
            "오후"
        }
    }
}

/// 12시간제에서 시간의 네임스페이스
enum Hour: Int, CaseIterable, Hashable, CustomStringConvertible {
    case one = 1, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve
    
    var description: String {
        "\(self.rawValue)시"
    }
}
