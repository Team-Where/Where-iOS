//
//  BulletPointModifier.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
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
