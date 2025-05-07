//
//  TextField.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import SwiftUI

// MARK: - TextField+CharacterLimit
extension TextField {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

extension RoundedTextField {
    func characterLimit(text: Binding<String>, limit: Int) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}
