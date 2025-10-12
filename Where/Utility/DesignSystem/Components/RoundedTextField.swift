//
//  RoundedTextField.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
    let lineColor: Color
    let disabled: Bool
    let font: WhereFont
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .whereFont(font)
            .foregroundStyle(Color(hex: 0x1F2937))
            .frame(minHeight: 56)
            .overlay(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(lineColor)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(disabled ? .gray : .clear)
                    .opacity(disabled ? 0.4 : 1.0)
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .replaceDisabled()
    }
}

struct RoundedTextField: View {
    private let titleKey: String
    private let text: Binding<String>
    private let prompt: Text
    private let axis: Axis
    private let textFieldStyle: RoundedTextFieldStyle
    
    init(
        _ titleKey: String,
        text: Binding<String>,
        font: WhereFont = .body16regular,
        disabled: Bool = false,
        lineColor: Color = .accent,
        axis: Axis = .horizontal
    ) {
        self.titleKey = titleKey
        self.text = text
        self.textFieldStyle = RoundedTextFieldStyle(lineColor: lineColor, disabled: disabled, font: font)
        self.prompt = Text(titleKey).foregroundStyle(Color(hex: 0x6B7280))
        self.axis = axis
    }
    
    var body: some View {
        TextField(titleKey, text: text, prompt: prompt, axis: axis)
            .textFieldStyle(textFieldStyle)
    }
    
    func secured() -> some View {
        SecureField(titleKey, text: text, prompt: prompt)
            .textFieldStyle(textFieldStyle)
    }
}
