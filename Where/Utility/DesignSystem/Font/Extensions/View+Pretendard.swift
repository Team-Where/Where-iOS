//
//  View+Pretendard.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI

private struct WhereFontViewModifier: ViewModifier {
    let font: WhereFont
    var name: String { font.pretendard.rawValue }
    var size: CGFloat { font.size }
    var lineHeight: CGFloat { font.lineHeight }
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
        let lineSpacing = lineHeight - uiFont.lineHeight
        
        content
            .font(.pretendard(font.pretendard, size: size))
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
}

extension View {
    func whereFont(_ whereFont: WhereFont) -> some View {
        modifier(WhereFontViewModifier(font: whereFont))
    }
}
