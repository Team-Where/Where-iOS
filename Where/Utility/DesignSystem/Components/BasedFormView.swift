//
//  BasedFormView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct BasedFormView<Content: View, Footer: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    private let header: Text
    private let content: () -> Content
    private let footer: () -> Footer
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        header: @autoclosure () -> Text,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.header = header()
        self.content = content
        self.footer = footer
    }
    
    init(
        _ header: any StringProtocol,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(content: content, header: Text(header), footer: footer)
    }
    
    var body: some View {
        VStack {
            header
                .whereFont(.title24semibold)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content()
            
            Spacer()
            
            footer()
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "arrow.backward")
                .padding(.leading, 14)
                .frame(width: 14, height: 12)
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    NavigationStack {
        BasedFormView("header here") {
            Text("content here")
        } footer: {
            Text("footer here")
        }
    }
}
