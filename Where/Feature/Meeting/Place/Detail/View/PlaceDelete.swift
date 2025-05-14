//
//  PlaceDelete.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct PlaceDelete: View {
    let isProcessing: Bool
    let onDelete: () -> Void
    
    init(
        isProcessing: Bool,
        onDelete: @escaping () -> Void
    ) {
        self.isProcessing = isProcessing
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Button {
                onDelete()
            } label: {
                if isProcessing {
                    ProgressView()
                } else {
                    Text("장소 삭제")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: 0xF3F4F6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 20)
            .disabled(isProcessing)
        }
        .presentationDetents([.height(148)])
        .presentationCornerRadius(16)
    }
}
