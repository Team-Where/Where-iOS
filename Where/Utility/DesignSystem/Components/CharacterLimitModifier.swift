//
//  CharacterLimitModifier.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import SwiftUI

struct CharacterLimitModifier: ViewModifier {
    @Binding var text: String
    let limit: Int
    
    func body(content: Content) -> some View {
        content
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > limit {
                    text = oldValue
                }
            }
    }
}
