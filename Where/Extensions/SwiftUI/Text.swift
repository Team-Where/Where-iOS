//
//  Text.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import SwiftUI

// MARK: - Text+BulletPoint
extension Text {
    func withBulletPoint() -> some View {
        modifier(BulletPointModifier())
    }
}
