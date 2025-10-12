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
    let isLoading: Bool
    
    init(
        _ disabled: Bool,
        _ foregroundColor: Color,
        _ backgroundColor: Color,
        _ isLoading: Bool
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.disabled = disabled || isLoading
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .tint(foregroundColor)
            } else {
                configuration.label
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(foregroundColor)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(disabled ? .where(hex: 0xDEE2E6) : backgroundColor)
        )
    }
}

extension ButtonStyle where Self == RoundedProminentButtonStyle {
    static func whereRoundedProminent(
        disabled: Bool = false,
        foreground: Color = .white,
        background: Color = .accent,
        isLoading: Bool = false
    ) -> RoundedProminentButtonStyle {
        RoundedProminentButtonStyle(disabled, foreground, background, isLoading)
    }
}
