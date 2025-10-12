//
//  DayOfWeek.swift
//  Where
//
//  Created by Swain Yun on 1/5/25.
//

import Foundation

/// 요일
///
/// - Note: 요일은 일요일부터 시작합니다. `CaseIterable`
enum DayOfWeek: String, CaseIterable {
    case sun = "일"
    case mon = "월"
    case tue = "화"
    case wed = "수"
    case thu = "목"
    case fri = "금"
    case sat = "토"
    
    static var count: Int { DayOfWeek.allCases.count }
    
    var inShortKorean: String {
        self.rawValue
    }
}

struct Day: Identifiable {
    let id: String = UUID().uuidString
    let day: Int
    let date: Date
    let isValid: Bool
    
    init(
        _ date: Date,
        _ day: Int,
        isValid: Bool
    ) {
        self.day = day
        self.date = date
        self.isValid = isValid
    }
}

struct Month: Identifiable {
    let id: String = UUID().uuidString
    let days: [Day]
    let startDate: Date
    
    init(
        _ days: [Day],
        _ startDate: Date
    ) {
        self.days = days
        self.startDate = startDate
    }
}
