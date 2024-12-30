//
//  RoundedProminentButtonStyle.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct RoundedProminentButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(
        _ foregroundColor: Color,
        _ backgroundColor: Color
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundStyle(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
    }
}

extension ButtonStyle where Self == RoundedProminentButtonStyle {
    static func whereRoundedProminent(
        _ foreground: Color = .white,
        _ background: Color = .accent
    ) -> RoundedProminentButtonStyle {
        RoundedProminentButtonStyle(foreground, background)
    }
}
