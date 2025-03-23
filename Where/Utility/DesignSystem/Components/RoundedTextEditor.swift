//
//  RoundedTextEditor.swift
//  Where
//
//  Created by Swain Yun on 3/23/25.
//

import SwiftUI

struct RoundedTextEditor: View {
    @Binding var text: String
    private let placeholder: String
    private let font: WhereFont
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        font: WhereFont = .body16regular
    ) {
        self.placeholder = placeholder
        self._text = text
        self.font = font
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .whereFont(font)
                .foregroundStyle(.where(.gray800))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.where(.gray200))
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if text.isEmpty {
                Text(placeholder)
                    .whereFont(font)
                    .foregroundStyle(.where(.gray500))
                    .padding(16)
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    RoundedTextEditor("내용을 입력해주세요", text: .constant(""))
        .padding()
}
