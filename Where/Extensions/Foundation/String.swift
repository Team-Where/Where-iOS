//
//  String.swift
//  Where
//
//  Created by Swain Yun on 5/7/25.
//

import Foundation

// MARK: - String+Format
extension String {
    func toDate(by dateFormat: DateFormat) -> Date? {
        let formatter = DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.date(from: self)
    }
}

// MARK: - String+RegularExpression
extension String {
    func isValidNickname() -> Bool {
        let pattern = "^[a-zA-Z0-9가-힣\\-_]{2,8}$"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: self.utf16.count)
            let matches = regex.matches(in: self, range: range)
            return !matches.isEmpty
        } catch {
            return false
        }
    }
}
