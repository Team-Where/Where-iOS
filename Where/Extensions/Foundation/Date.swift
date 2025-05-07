//
//  Date.swift
//  Where
//
//  Created by Swain Yun on 5/7/25.
//

import Foundation

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
    
    private static var cachedMonth: [Int: Month] = [:]
    
    private func monthCalculation(from date: Date) -> Month {
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
    
    private func cachedMonth(from date: Date) -> Month {
        let key = date.hashValue
        if let cached = Date.cachedMonth[key] {
            return cached
        }
        let month = monthCalculation(from: date)
        Date.cachedMonth[key] = month
        return month
    }
    
    func inSameDay(as date: Date) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }
    
    func month(from date: Date = .now) -> Month {
        cachedMonth(from: date)
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

// MARK: - Date+Compare
extension Date {
    /// '어디' 서비스의 '최근 만난 모임'이란 종료일로부터 한 달이 되지 않은 모임을 의미합니다.
    func isRecent(compareTo now: Date) -> Bool {
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
            return false
        }
        return self >= oneMonthAgo
    }
    
    /// 현재 시각과의 차이를 계산하여 상대적인 문자열을 반환합니다.
    /// - 60초 미만: "방금"
    /// - 1분 이상, 50분 미만: "N분 전"
    /// - 0일: "오늘"
    /// - 1일: "어제"
    /// - 2일 이상, 30일 이하: "N일 전"
    /// - 30일 초과: "MM월 dd일"
    func relativeTimeDisplay() -> String {
        let now = Date.now
        let components = calendar.dateComponents([.second, .minute, .day], from: self, to: now)
        
        if let seconds = components.second, seconds < 60 {
            return "방금"
        } else if let minutes = components.minute, minutes < 60 {
            return "\(minutes)분 전"
        } else if let days = components.day {
            if days == .zero {
                return "오늘"
            } else if days == 1 {
                return "어제"
            } else if days <= 30 {
                return "\(days)일 전"
            } else {
                return self.toString(by: .MMddKorean)
            }
        }
        
        return self.toString(by: .MMddKorean)
    }
}

// MARK: - Date+Format
extension Date {
    func toString(by dateFormat: DateFormat) -> String {
        let formatter = DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
    
    /// DateFormat에서 제공하는 형태와 다른 날짜 형식일 경우 사용
    func toString(by dateFormat: String) -> String {
        let formatter = DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
}
