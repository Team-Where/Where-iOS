//
//  RoundedProminentButtonStyle.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct RoundedProminentButtonStyle: ButtonStyle {
    let disabled: Bool
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(
        _ disabled: Bool,
        _ foregroundColor: Color,
        _ backgroundColor: Color
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundStyle(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(disabled ? Color(hex: 0xDEE2E6) : backgroundColor)
            )
    }
}

extension ButtonStyle where Self == RoundedProminentButtonStyle {
    static func whereRoundedProminent(
        _ disabled: Bool = false,
        _ foreground: Color = .white,
        _ background: Color = .accent
    ) -> RoundedProminentButtonStyle {
        RoundedProminentButtonStyle(disabled, foreground, background)
    }
}
