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
        _ day: Int = .zero
    ) {
        self.day = day
        self.date = date
        self.isValid = day > .zero
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

// MARK: Extensions
extension Date {
    private var calendar: Calendar { Calendar.current }
    
    var isDateInToday: Bool {
        calendar.isDateInToday(self)
    }
    
    var startOfDay: Date {
        calendar.startOfDay(for: self)
    }
    
    var startOfMonth: Date? {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self))
    }
    
    var numberOfWeeks: CGFloat {
        guard let range = calendar.range(of: .weekOfMonth, in: .month, for: self) else {
            return .zero
        }
        return CGFloat(range.count)
    }
    
    func inSameDay(as date: Date) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }
    
    func month(from date: Date = .now) -> Month {
//        guard let start = date.startOfMonth,
//              let dayRange = calendar.range(of: .day, in: .month, for: start)
//        else {
//            return Month()
//        }
//        
//        let daysOfWeek = DayOfWeek.allCases
//        let month = calendar.component(.month, from: start)
//        let days: [Day] = dayRange.compactMap { day in
//            guard let date = calendar.date(byAdding: .day, value: day - 1, to: start) else { return nil }
//            let dayOfWeek = daysOfWeek[calendar.component(.weekday, from: date) - 1]
//            return Day(dayOfWeek, day, date)
//        }
//        
//        return Month(month, days)
        
        guard let startOfMonth = date.startOfMonth,
              let dayRange = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return Month([], .now) }
        let firstWeekDay = calendar.component(.weekday, from: startOfMonth)
        
        let emptyDays = Array(repeating: Day(self), count: firstWeekDay - 1)
        let daysInMonth: [Day] = dayRange.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
            return Day(date, day)
        }
        
        return Month(emptyDays + daysInMonth, startOfMonth)
    }
    
    func previousMonth() -> Month {
        guard let start = calendar.date(byAdding: .month, value: -1, to: self) else {
            return Month([], .now)
        }
        
        return self.month(from: start)
    }
    
    func nextMonth() -> Month {
        guard let start = calendar.date(byAdding: .month, value: 1, to: self) else {
            return Month([], .now)
        }
        
        return self.month(from: start)
    }
}
