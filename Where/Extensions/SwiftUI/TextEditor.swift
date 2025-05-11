//
//  TextEditor.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import SwiftUI

extension TextEditor {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

extension RoundedTextEditor {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}
