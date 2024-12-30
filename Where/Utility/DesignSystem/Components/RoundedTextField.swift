//
//  RoundedTextField.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
    let color: Color
    let disabled: Bool
    let font: WhereFont?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .whereFont(font ?? .body16regular)
            .overlay(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(disabled ? .gray : .clear)
                    .opacity(disabled ? 0.4 : 1.0)
            }
    }
}

struct RoundedTextField: View {
    private let titleKey: String
    private let text: Binding<String>
    private let font: WhereFont?
    private let axis: Axis
    private let lineLimit: (start: Int, end: Int)
    private let disabled: Bool
    private let color: Color
    private let isSecured: Bool
    
    init(
        _ titleKey: String,
        text: Binding<String>,
        font: WhereFont? = nil,
        axis: Axis = .horizontal,
        lineLimit: (start: Int, end: Int) = (1, 10),
        disabled: Bool = false,
        color: Color = .accent,
        isSecured: Bool = false
    ) {
        self.titleKey = titleKey
        self.text = text
        self.font = font
        self.axis = axis
        self.lineLimit = lineLimit
        self.disabled = disabled
        self.color = color
        self.isSecured = isSecured
    }
    
    var body: some View {
        textField()
            .textFieldStyle(RoundedTextFieldStyle(color: color, disabled: disabled, font: font))
            .disabled(disabled)
            .lineLimit(lineLimit.start...lineLimit.end)
            .autocorrectionDisabled()
            .replaceDisabled()
    }
    
    @ViewBuilder private func textField() -> some View {
        if isSecured {
            SecureField(titleKey, text: text)
        } else {
            TextField(titleKey, text: text, axis: axis)
        }
    }
}
