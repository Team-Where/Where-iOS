//
//  Color Extension.swift
//  Where
//
//  Created by 이현호 on 12/29/24.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension ShapeStyle where Self == Color {
    static func `where`(_ type: WhereColor) -> Color { type.color() }
    static func `where`(hex: UInt) -> Color { Color(hex: hex) }
}

protocol WhereColorProtocol: RawRepresentable where RawValue == UInt {
    var hex: RawValue { get }
    
    func color() -> Color
}

extension WhereColorProtocol {
    var hex: RawValue { self.rawValue }
    
    func color() -> Color { Color(hex: hex) }
}

enum WhereColor: UInt, WhereColorProtocol {
    // Neutral Colors
    /// 0xF9FAFB
    case gray50 = 0xF9FAFB
    /// 0xF3F4F6
    case gray100 = 0xF3F4F6
    /// 0xE5E7EB
    case gray200 = 0xE5E7EB
    /// 0xD1D5DB
    case gray300 = 0xD1D5DB
    /// 0x9CA3AF
    case gray400 = 0x9CA3AF
    /// 0x6B7280
    case gray500 = 0x6B7280
    /// 0x4B5563
    case gray600 = 0x4B5563
    /// 0x374151
    case gray700 = 0x374151
    /// 0x1F2937
    case gray800 = 0x1F2937
    /// 0x111827
    case gray900 = 0x111827
    
    // Primary Colors
    /// 0xEEF2FF
    case indigo50 = 0xEEF2FF
    /// 0xE0E7FF
    case indigo100 = 0xE0E7FF
    /// 0xC7D2FE
    case indigo200 = 0xC7D2FE
    /// 0xA5B4FC
    case indigo300 = 0xA5B4FC
    /// 0x818CF8
    case indigo400 = 0x818CF8
    /// 0x6366F1
    case indigo500 = 0x6366F1
    /// 0x4F46E5
    case indigo600 = 0x4F46E5
    /// 0x4338CA
    case indigo700 = 0x4338CA
    /// 0x3730A3
    case indigo800 = 0x3730A3
    /// 0x312E81
    case indigo900 = 0x312E81

    // Semantic Colors
    /// 0xFEF2F2
    case red50 = 0xFEF2F2
    /// 0xFEE2E2
    case red100 = 0xFEE2E2
    /// 0xFECACA
    case red200 = 0xFECACA
    /// 0xFCA5A5
    case red300 = 0xFCA5A5
    /// 0xF87171
    case red400 = 0xF87171
    /// 0xEF4444
    case red500 = 0xEF4444
    /// 0xDC2626
    case red600 = 0xDC2626
    /// 0xB91C1C
    case red700 = 0xB91C1C
    /// 0x991B1B
    case red800 = 0x991B1B
    /// 0x7F1D1D
    case red900 = 0x7F1D1D

    /// 0xFFF7ED
    case orange50 = 0xFFF7ED
    /// 0xFFEDD5
    case orange100 = 0xFFEDD5
    /// 0xFED7A7
    case orange200 = 0xFED7A7
    /// 0xFDBA74
    case orange300 = 0xFDBA74
    /// 0xFB923C
    case orange400 = 0xFB923C
    /// 0xF97316
    case orange500 = 0xF97316
    /// 0xEA580C
    case orange600 = 0xEA580C
    /// 0xC2410C
    case orange700 = 0xC2410C
    /// 0x9A3412
    case orange800 = 0x9A3412
    /// 0x7C2D12
    case orange900 = 0x7C2D12

    /// 0xFFFBEA
    case amber50 = 0xFFFBEA
    /// 0xFEF3C7
    case amber100 = 0xFEF3C7
    /// 0xFDE68A
    case amber200 = 0xFDE68A
    /// 0xFCD34D
    case amber300 = 0xFCD34D
    /// 0xFBFB24
    case amber400 = 0xFBFB24
    /// 0xF59E0B
    case amber500 = 0xF59E0B
    /// 0xD97706
    case amber600 = 0xD97706
    /// 0xB45309
    case amber700 = 0xB45309
    /// 0x92400E
    case amber800 = 0x92400E
    /// 0x78350F
    case amber900 = 0x78350F

    /// 0xF0FDF4
    case green50 = 0xF0FDF4
    /// 0xDCFCE7
    case green100 = 0xDCFCE7
    /// 0xBBF7D0
    case green200 = 0xBBF7D0
    /// 0x86EFAC
    case green300 = 0x86EFAC
    /// 0x4ADE80
    case green400 = 0x4ADE80
    /// 0x22C55E
    case green500 = 0x22C55E
    /// 0x16A34A
    case green600 = 0x16A34A
    /// 0x15803D
    case green700 = 0x15803D
    /// 0x166534
    case green800 = 0x166534
    /// 0x14532D
    case green900 = 0x14532D

    /// 0xEFF6FF
    case blue50 = 0xEFF6FF
    /// 0xDBEAFE
    case blue100 = 0xDBEAFE
    /// 0xBFDBFE
    case blue200 = 0xBFDBFE
    /// 0x93C5FD
    case blue300 = 0x93C5FD
    /// 0x60A5FA
    case blue400 = 0x60A5FA
    /// 0x3B82F6
    case blue500 = 0x3B82F6
    /// 0x2563EB
    case blue600 = 0x2563EB
    /// 0x1D4ED8
    case blue700 = 0x1D4ED8
    /// 0x1E40AF
    case blue800 = 0x1E40AF
    /// 0x1E3A8A
    case blue900 = 0x1E3A8A
}
