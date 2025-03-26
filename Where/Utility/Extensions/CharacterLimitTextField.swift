//
//  CharacterLimitTextField.swift
//  Where
//
//  Created by Swain Yun on 3/26/25.
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

extension TextField {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

extension TextEditor {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

extension RoundedTextField {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

extension RoundedTextEditor {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}
