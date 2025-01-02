//
//  FloaterView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

struct FloaterView<Title: StringProtocol>: View {
    @Binding var isFloaterPresented: Bool
    let title: Title
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .foregroundStyle(.accent)
            
            Text(title)
                .whereFont(.body14medium)
                .foregroundStyle(.white)
            
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal)
        .background(Color(hex: 0x030712))
        .clipShape(.rect(cornerRadius: 8))
        .padding(.bottom)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isFloaterPresented = false
            }
        }
    }
}
