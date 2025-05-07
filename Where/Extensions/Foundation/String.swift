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
