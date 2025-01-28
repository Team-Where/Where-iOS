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
    static var `where`: WhereColor { WhereColor() }
}

struct WhereColor {
    // Neutral Colors
    /// 0xF9FAFB
    let gray50: Color = NeutralHex.gray50.color()
    /// 0xF3F4F6
    let gray100: Color = NeutralHex.gray100.color()
    /// 0xE5E7EB
    let gray200: Color = NeutralHex.gray200.color()
    /// 0xD1D5DB
    let gray300: Color = NeutralHex.gray300.color()
    /// 0x9CA3AF
    let gray400: Color = NeutralHex.gray400.color()
    /// 0x6B7280
    let gray500: Color = NeutralHex.gray500.color()
    /// 0x4B5563
    let gray600: Color = NeutralHex.gray600.color()
    /// 0x374151
    let gray700: Color = NeutralHex.gray700.color()
    /// 0x1F2937
    let gray800: Color = NeutralHex.gray800.color()
    /// 0x111827
    let gray900: Color = NeutralHex.gray900.color()
    
    // Primary Colors
    /// 0xEEF2FF
    let indigo50: Color = PrimaryHex.indigo50.color()
    /// 0xE0E7FF
    let indigo100: Color = PrimaryHex.indigo100.color()
    /// 0xC7D2FE
    let indigo200: Color = PrimaryHex.indigo200.color()
    /// 0xA5B4FC
    let indigo300: Color = PrimaryHex.indigo300.color()
    /// 0x818CF8
    let indigo400: Color = PrimaryHex.indigo400.color()
    /// 0x6366F1
    let indigo500: Color = PrimaryHex.indigo500.color()
    /// 0x4F46E5
    let indigo600: Color = PrimaryHex.indigo600.color()
    /// 0x4338CA
    let indigo700: Color = PrimaryHex.indigo700.color()
    /// 0x3730A3
    let indigo800: Color = PrimaryHex.indigo800.color()
    /// 0x312E81
    let indigo900: Color = PrimaryHex.indigo900.color()

    // Semantic Colors
    /// 0xFEF2F2
    let red50: Color = SemanticHex.red50.color()
    /// 0xFEE2E2
    let red100: Color = SemanticHex.red100.color()
    /// 0xFECACA
    let red200: Color = SemanticHex.red200.color()
    /// 0xFCA5A5
    let red300: Color = SemanticHex.red300.color()
    /// 0xF87171
    let red400: Color = SemanticHex.red400.color()
    /// 0xEF4444
    let red500: Color = SemanticHex.red500.color()
    /// 0xDC2626
    let red600: Color = SemanticHex.red600.color()
    /// 0xB91C1C
    let red700: Color = SemanticHex.red700.color()
    /// 0x991B1B
    let red800: Color = SemanticHex.red800.color()
    /// 0x7F1D1D
    let red900: Color = SemanticHex.red900.color()

    /// 0xFFF7ED
    let orange50: Color = SemanticHex.orange50.color()
    /// 0xFFEDD5
    let orange100: Color = SemanticHex.orange100.color()
    /// 0xFED7A7
    let orange200: Color = SemanticHex.orange200.color()
    /// 0xFDBA74
    let orange300: Color = SemanticHex.orange300.color()
    /// 0xFB923C
    let orange400: Color = SemanticHex.orange400.color()
    /// 0xF97316
    let orange500: Color = SemanticHex.orange500.color()
    /// 0xEA580C
    let orange600: Color = SemanticHex.orange600.color()
    /// 0xC2410C
    let orange700: Color = SemanticHex.orange700.color()
    /// 0x9A3412
    let orange800: Color = SemanticHex.orange800.color()
    /// 0x7C2D12
    let orange900: Color = SemanticHex.orange900.color()

    /// 0xFFFBEA
    let amber50: Color = SemanticHex.amber50.color()
    /// 0xFEF3C7
    let amber100: Color = SemanticHex.amber100.color()
    /// 0xFDE68A
    let amber200: Color = SemanticHex.amber200.color()
    /// 0xFCD34D
    let amber300: Color = SemanticHex.amber300.color()
    /// 0xFBFB24
    let amber400: Color = SemanticHex.amber400.color()
    /// 0xF59E0B
    let amber500: Color = SemanticHex.amber500.color()
    /// 0xD97706
    let amber600: Color = SemanticHex.amber600.color()
    /// 0xB45309
    let amber700: Color = SemanticHex.amber700.color()
    /// 0x92400E
    let amber800: Color = SemanticHex.amber800.color()
    /// 0x78350F
    let amber900: Color = SemanticHex.amber900.color()

    /// 0xF0FDF4
    let green50: Color = SemanticHex.green50.color()
    /// 0xDCFCE7
    let green100: Color = SemanticHex.green100.color()
    /// 0xBBF7D0
    let green200: Color = SemanticHex.green200.color()
    /// 0x86EFAC
    let green300: Color = SemanticHex.green300.color()
    /// 0x4ADE80
    let green400: Color = SemanticHex.green400.color()
    /// 0x22C55E
    let green500: Color = SemanticHex.green500.color()
    /// 0x16A34A
    let green600: Color = SemanticHex.green600.color()
    /// 0x15803D
    let green700: Color = SemanticHex.green700.color()
    /// 0x166534
    let green800: Color = SemanticHex.green800.color()
    /// 0x14532D
    let green900: Color = SemanticHex.green900.color()

    /// 0xEFF6FF
    let blue50: Color = SemanticHex.blue50.color()
    /// 0xDBEAFE
    let blue100: Color = SemanticHex.blue100.color()
    /// 0xBFDBFE
    let blue200: Color = SemanticHex.blue200.color()
    /// 0x93C5FD
    let blue300: Color = SemanticHex.blue300.color()
    /// 0x60A5FA
    let blue400: Color = SemanticHex.blue400.color()
    /// 0x3B82F6
    let blue500: Color = SemanticHex.blue500.color()
    /// 0x2563EB
    let blue600: Color = SemanticHex.blue600.color()
    /// 0x1D4ED8
    let blue700: Color = SemanticHex.blue700.color()
    /// 0x1E40AF
    let blue800: Color = SemanticHex.blue800.color()
    /// 0x1E3A8A
    let blue900: Color = SemanticHex.blue900.color()
}


protocol WhereColorProtocol: RawRepresentable where RawValue == UInt {
    var hex: RawValue { get }
    
    func color() -> Color
}

extension WhereColorProtocol {
    var hex: RawValue { self.rawValue }
    
    func color() -> Color { Color(hex: hex) }
}

enum NeutralHex: UInt, WhereColorProtocol {
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
}

enum PrimaryHex: UInt, WhereColorProtocol {
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
}

enum SemanticHex: UInt, WhereColorProtocol {
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
