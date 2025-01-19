//
//  BackButton.swift
//  Where
//
//  Created by 이현호 on 1/18/25.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    let action: (() -> Void)?
    
    init(action: (() -> Void)? = nil) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action?()
            dismiss()
        } label: {
            Image(systemName: "arrow.backward")
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    BackButton()
}
