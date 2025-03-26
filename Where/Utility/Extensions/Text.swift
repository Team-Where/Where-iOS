//
//  Text.swift
//  Where
//
//  Created by Swain Yun on 3/26/25.
//

import SwiftUI

struct BulletPointModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\u{2022}")
            content
        }
    }
}

extension Text {
    func withBulletPoint() -> some View {
        modifier(BulletPointModifier())
    }
}
