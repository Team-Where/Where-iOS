//
//  PlaceDelete.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct PlaceDelete: View {
    var body: some View {
        VStack(spacing: 16) {
            Button {
            
            } label: {
                Text("장소 삭제")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: 0xF3F4F6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    PlaceDelete()
}
