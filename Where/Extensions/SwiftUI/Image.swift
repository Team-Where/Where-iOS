//
//  Image.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import SwiftUI

// MARK: - Image+RoundedImage
extension Image {
    func rounded(contentMode: ContentMode, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        modifier(RoundedImageModifier(contentMode: contentMode, width: width, height: height, cornerRadius: cornerRadius))
    }
}
