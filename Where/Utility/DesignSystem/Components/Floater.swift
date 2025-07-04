//
//  Floater.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

protocol FloaterContent {
    var title: String { get }
}

struct FloaterModifier<Icon: View>: ViewModifier {
    @Binding var isFloaterPresented: Bool
    let title: String
    let icon: (() -> Icon)?
    
    init(
        _ isFloaterPresented: Binding<Bool>,
        _ title: String,
        _ icon: (() -> Icon)?
    ) {
        self._isFloaterPresented = isFloaterPresented
        self.title = title
        self.icon = icon
    }
    
    func body(content: Content) -> some View {
        Floater($isFloaterPresented, basedContent: content, title, icon)
    }
}

struct Floater<Based: View, Icon: View>: View {
    @Binding var isFloaterPresented: Bool
    
    private let basedContent: Based
    private let title: String
    private let icon: (() -> Icon)?
    
    init(
        _ isFloaterPresented: Binding<Bool>,
        basedContent: Based,
        _ title: String,
        _ icon: (() -> Icon)?
    ) {
        self._isFloaterPresented = isFloaterPresented
        self.basedContent = basedContent
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            basedContent
            
            if isFloaterPresented {
                FloaterView(isFloaterPresented: $isFloaterPresented, title: title, icon: icon?())
                    .padding(.horizontal)
            }
        }
    }
}

struct FloaterView<Icon: View>: View {
    @Binding var isFloaterPresented: Bool
    let title: String
    let icon: Icon?
    
    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                icon
            }
            
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
