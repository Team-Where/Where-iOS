//
//  RadioButton.swift
//  Where
//
//  Created by Swain Yun on 3/23/25.
//

import SwiftUI

protocol RadioButtonSelection: Identifiable, Hashable, CaseIterable {
    var title: String { get }
}

extension RadioButtonSelection {
    var id: Int { self.hashValue }
}

struct RadioButton<Selection: RadioButtonSelection>: View {
    @Binding var selectedValue: Selection?
    let value: Selection
    
    var isOn: Bool { selectedValue == value }
    
    var body: some View {
        Button {
            selectedValue = value
        } label: {
            HStack(spacing: 12) {
                radio()
                label()
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func radio() -> some View {
        Circle()
            .strokeBorder(isOn ? .accent : .where(.gray500), lineWidth: isOn ? 6 : 1)
            .foregroundStyle(.white)
            .frame(width: 18, height: 18)
    }
    
    @ViewBuilder private func label() -> some View {
        Text(value.title)
            .whereFont(.body14regular)
            .foregroundStyle(isOn ? .black : .where(hex: 0x6B7280))
    }
}
