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

// MARK: Extensions
extension Date {
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        return calendar
    }
    
    var startOfMonth: Date? {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self))
    }
    
    var startOfPreviousMonth: Date? {
        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: self)
        return lastMonthDate?.startOfMonth
    }
    
    var rangeOfDays: Range<Int>? {
        calendar.range(of: .day, in: .month, for: self)
    }
    
    func inSameDay(as date: Date) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }
    
    func month(from date: Date = .now) -> Month {
        let rowsCount: Int = 6
        let totalDays: Int = rowsCount * 7
        
        guard let startOfMonth = date.startOfMonth,
              let dayRange = startOfMonth.rangeOfDays
        else { return Month([], .now) }
        
        let firstWeekDay = calendar.component(.weekday, from: startOfMonth)
        
        let emptyDays: [Day] = (0..<firstWeekDay - 1).reversed().compactMap { offset in
            let previousDate = calendar.date(byAdding: .day, value: -offset - 1, to: startOfMonth)
            guard let date = previousDate else { return nil }
            let day = calendar.component(.day, from: date)
            return Day(date, day, isValid: false)
        }
        
        let daysInMonth: [Day] = dayRange.compactMap { day in
            guard let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
            let components = calendar.dateComponents([.year, .month, .day], from: dayDate)
            guard let normalizedDay = calendar.date(from: components) else { return nil }
            return Day(normalizedDay, day, isValid: true)
        }
        
        var days = emptyDays + daysInMonth
        if days.count < totalDays {
            let additionalDaysCount = totalDays - days.count
            
            guard let nextMonthStartDate = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
                  let firstDayOfNextMonth = nextMonthStartDate.startOfMonth else {
                return Month(days, startOfMonth)
            }
            
            let nextDays: [Day] = (0..<additionalDaysCount).compactMap { index in
                guard let nextDate = calendar.date(byAdding: .day, value: index, to: firstDayOfNextMonth) else { return nil }
                return Day(nextDate, calendar.component(.day, from: nextDate), isValid: false)
            }
            days.append(contentsOf: nextDays)
        }
        
        return Month(days, startOfMonth)
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
    
    /// 날짜 및 시간 정보를 취합해 반환
    ///
    /// - Parameters:
    ///     * hour: 선택한 시간 값
    ///     * meridiem: 선택한 오전, 오후 중 값
    ///
    /// - Returns:
    ///     주어진 날짜 및 시간 정보를 취합한 값
    func combine(hour: Hour?, meridiem: Meridiem?) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        let hour = hour?.rawValue
        
        switch meridiem {
        case .am:
            components.hour = hour == 12 ? 0 : hour
        case .pm:
            components.hour = hour == 12 ? 12 : (hour ?? 0) + 12
        case nil:
            break
        }
        
        let combinedDate = calendar.date(from: components)
        return combinedDate
    }
    
    func dateComponents() -> DateComponents {
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return components
    }
}
