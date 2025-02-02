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
            }
        }
    }
}

struct FloaterView<Icon: View>: View {
    var isFloaterPresented: Binding<Bool>
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
                isFloaterPresented.wrappedValue = false
            }
        }
    }
}

extension View {
    func floater<Icon: View>(
        _ isPresented: Binding<Bool>,
        title: String,
        icon: (() -> Icon)? = nil
    ) -> some View {
        modifier(FloaterModifier<Icon>(isPresented, title, icon))
    }
    
    func floater<Item: FloaterContent, Icon: View>(
        _ item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Icon
    ) -> some View {
        let isPresented = Binding<Bool> { item.wrappedValue != nil } set: { if $0 == false { item.wrappedValue = nil } }
        let title = item.wrappedValue?.title ?? String()
        return modifier(FloaterModifier(isPresented, title, { item.wrappedValue.map(content) }))
    }
}
