//
//  RoundedImageModifier.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import SwiftUI

struct RoundedImageModifier: ViewModifier {
    let contentMode: ContentMode
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: contentMode)
            .frame(width: width, height: height)
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}
