//
//  Meridiem.swift
//  Where
//
//  Created by Swain Yun on 1/9/25.
//

import Foundation

enum Meridiem: CaseIterable, Hashable {
    case am, pm
    
    var koreanDescription: String {
        switch self {
        case .am:
            "오전"
        case .pm:
            "오후"
        }
    }
}
