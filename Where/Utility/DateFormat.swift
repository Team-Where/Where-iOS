//
//  DateFormat.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import Foundation

/// 날짜, 시간 표현 방식
enum DateFormat: String {
    /// 년.월.일
    case yyyyMMdd = "yyyy.MM.dd"
    
    /// 년-월-일
    case yyyyMMddHyphen = "yyyy-MM-dd"
    
    /// 년월일 (구분자 없음)
    case yyyyMMddRaw
    
    /// 한국어 년월일 (yyyy년 MM월 dd일)
    case yyyyMMddKorean = "yyyy년 MM월 dd일"
    
    /// 한국어 년월일 (yyyy년 M월 d일)
    case yyyyMdKorean = "yyyy년 M월 d일"
    
    /// 한국어 월일 (MM월 dd일)
    case MMddKorean = "MM월 dd일"
    
    /// 한국어 월일 (M월 d일)
    case MdKorean = "M월 d일"
    
    /// 년.월
    case yyyyMM = "yyyy.MM"
    
    /// 월.일
    case MMdd = "MM.dd"
    
    /// 년.월.일 시:분:초
    case dateTime = "yyyy.MM.dd HH:mm:ss"
    
    /// 년.월.일 시:분
    case yyyyMMddHHmm = "yyyy.MM.dd HH:mm"
    
    /// 년.월.일 오전/오후 시(12)
    case yyyyMMddah = "yyyy.MM.dd a h시"
    
    /// 년.월.일 오전/오후 시:분
    case yyyyMMddahhmm = "yyyy.MM.dd a hh:mm"
    
    /// 년.월.일 오전/오후 시(24):분
    case yyyyMMddaHHmm = "yyyy.MM.dd a HH:mm"
    
    /// 시:분:초
    case HHmmss = "HH:mm:ss"
    
    /// 시:분
    case HHmm = "HH:mm"
    
    /// 오전/오후 시:분
    case ahhmm = "a hh:mm"
    
    /// 오전/오후 시:분
    /// - Note: 숫자가 0으로 시작하지 않음
    case ahmm = "a h:mm"
    
    /// 축약 요일 (월, 화)
    case ee = "EE"
    
    /// 서버 날짜, 시간 (년-월-일'시각구분'시:분:초)
    case serverDateTime1 = "yyyy-MM-dd'T'HH:mm:ss"
    
    /// 서버 날짜, 시간 (년-월-일 시:분:초)
    case serverDateTime2 = "yyyy-MM-dd HH:mm:ss"
}

// MARK: DateFormatter 관련
extension DateFormat {
    private static let dateFormatterCached = DateFormatterCached()
    
    /**
     각 DateFormat에 대응되는 DateFormatter
     
     * DateFormatter를 매번 생성하지 않고 재사용 하려는 목적으로 사용
     
     */
    static func cachedFormatter(dateFormat: String) async -> DateFormatter {
        await dateFormatterCached.cachedFormatter(for: dateFormat)
    }
    
    /**
     각 DateFormat에 대응되는 DateFormatter
     
     * DateFormatter를 매번 생성하지 않고 재사용 하려는 목적으로 사용
     
     */
    static func cachedFormatter(dateFormat: DateFormat) async -> DateFormatter {
        await dateFormatterCached.cachedFormatter(for: dateFormat.rawValue)
    }
    
    static func toDate(iso8601String: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: iso8601String)
        return date
    }
}

actor DateFormatterCached {
    private var cachedFormatters = [String: DateFormatter]()
    
    func cachedFormatter(for dateFormat: String) -> DateFormatter {
        if let cached = cachedFormatters[dateFormat] {
            return cached
        }
        
        let formatter = createFormatter(with: dateFormat)
        cachedFormatters[dateFormat] = formatter
        return formatter
    }
    
    private func createFormatter(with dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
}

// MARK: Date+Format
extension Date {
    func toString(by dateFormat: DateFormat) async -> String {
        let formatter = await DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
    
    /// DateFormat에서 제공하는 형태와 다른 날짜 형식일 경우 사용
    func toString(by dateFormat: String) async -> String {
        let formatter = await DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
}

extension String {
    func toDate(by dateFormat: DateFormat) async -> Date? {
        let formatter = await DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.date(from: self)
    }
}
