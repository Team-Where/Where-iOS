//
//  Popup.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct PopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPopupPresented: Bool
    
    private let popupContent: PopupContent
    
    init(
        _ isPopupPresented: Binding<Bool>,
        @ViewBuilder popupContent: @escaping () -> PopupContent
    ) {
        self._isPopupPresented = isPopupPresented
        self.popupContent = popupContent()
    }
    
    func body(content: Content) -> some View {
        Popup($isPopupPresented, basedContent: content) {
            popupContent
        }
    }
}

struct Popup<Based: View, Popup: View>: View {
    @Binding var isPopupPresented: Bool
    
    private let basedContent: Based
    private let popupContent: Popup
    
    init(
        _ isPopupPresented: Binding<Bool>,
        basedContent: Based,
        @ViewBuilder popupContent: @escaping () -> Popup
        
    ) {
        self._isPopupPresented = isPopupPresented
        self.basedContent = basedContent
        self.popupContent = popupContent()
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(isPopupPresented ? 0.4 : 0)
                .ignoresSafeArea(edges: .all)
            
            basedContent
            
            if isPopupPresented {
                popupContent
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding()
                    .padding()
            }
        }
    }
}

extension View {
    func popup(
        _ isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(PopupModifier(isPresented, popupContent: content))
    }
}
