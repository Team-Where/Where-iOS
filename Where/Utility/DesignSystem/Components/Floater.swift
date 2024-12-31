//
//  Floater.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

struct FloaterModifier<FloaterContent: StringProtocol>: ViewModifier {
    @Binding var isFloaterPresented: Bool
    
    private let floaterContent: FloaterContent
    
    init(
        _ isFloaterPresented: Binding<Bool>,
        floaterContent: FloaterContent
    ) {
        self._isFloaterPresented = isFloaterPresented
        self.floaterContent = floaterContent
    }
    
    func body(content: Content) -> some View {
        Floater($isFloaterPresented, basedContent: content, floaterContent: floaterContent)
    }
}

struct Floater<Based: View, Floater: StringProtocol>: View {
    @Binding var isFloaterPresented: Bool
    
    private let basedContent: Based
    private let floaterContent: Floater
    
    init(
        _ isFloaterPresented: Binding<Bool>,
        basedContent: Based,
        floaterContent: Floater
    ) {
        self._isFloaterPresented = isFloaterPresented
        self.basedContent = basedContent
        self.floaterContent = floaterContent
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            basedContent
            
            if isFloaterPresented {
                FloaterView(isFloaterPresented: $isFloaterPresented, title: floaterContent)
            }
        }
    }
}

extension View {
    func floater<Message: StringProtocol>(
        _ isPresented: Binding<Bool>,
        message: Message
    ) -> some View {
        modifier(FloaterModifier(isPresented, floaterContent: message))
    }
}
