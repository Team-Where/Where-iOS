//
//  Image.swift
//  Where
//
//  Created by BOMBSGIE on 4/25/25.
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

extension Image {
    func rounded(contentMode: ContentMode, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        modifier(RoundedImageModifier(contentMode: contentMode, width: width, height: height, cornerRadius: cornerRadius))
    }
}
