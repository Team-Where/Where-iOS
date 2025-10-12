//
//  WhereFormModifier.swift
//  Where
//
//  Created by Swain Yun on 3/2/25.
//

import SwiftUI

struct WhereFormModifier<ActionButton: View>: ViewModifier {
    let navigationTitle: String
    let actionButton: ActionButton
    
    init(_ navigationTitle: String, actionButton: ActionButton) {
        self.navigationTitle = navigationTitle
        self.actionButton = actionButton
    }
    
    func body(content: Content) -> some View {
        VStack {
            Text(navigationTitle)
                .whereFont(.title24semibold)
                .foregroundStyle(.where(.gray800))
                .multilineTextAlignment(.leading)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content
            
            Spacer()
            
            actionButton
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
        }
    }
}
