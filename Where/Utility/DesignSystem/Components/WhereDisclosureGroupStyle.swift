//
//  WhereDisclosureGroupStyle.swift
//  Where
//
//  Created by Swain Yun on 3/22/25.
//

import SwiftUI

struct WhereDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack {
                    configuration.label
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .rotationEffect(configuration.isExpanded ? .degrees(-180) : .degrees(0))
                        .animation(.easeInOut(duration: 0.2), value: configuration.isExpanded)
                        .foregroundStyle(.where(.gray500))
                        .frame(width: 8, height: 4)
                }
                .frame(height: 60)
            }
            .buttonStyle(.plain)
            
            if configuration.isExpanded {
                configuration.content
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray700))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.where(.gray100))
                    )
            }
        }
        .padding(.horizontal)
    }
}
