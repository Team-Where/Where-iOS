//
//  SideMenuView.swift
//  Where
//
//  Created by 이현호 on 2/8/25.
//

import SwiftUI

public struct SideMenuView<Content>: View where Content: View {
    @Binding public var isPresented: Bool
    public var width: CGFloat
    public var content: Content
    
    @GestureState private var translation: CGFloat = .zero
    
    public init(_ isPresented: Binding<Bool>, width: CGFloat, content: () -> Content) {
        self._isPresented = isPresented
        self.width = width
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top) {
                Spacer()
                
                ZStack(alignment: .top) {
                    Color.white
                    
                    VStack(spacing: 0) {
                        Rectangle()
                            .frame(height: geometry.safeAreaInsets.top)
                            .foregroundStyle(.white)
                        
                        self.content
                    }
                }
                .frame(width: self.width)
            }
            .transition(.opacity.combined(with: .move(edge: .trailing)))
            .offset(x: translation)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        if 0 <= value.translation.width {
                            let translation = min(self.width, max(-self.width, value.translation.width))
                            state = translation
                        }
                    }
                    .onEnded({ value in
                        if value.translation.width >= width/3 {
                            self.isPresented = false
                        }
                    })
            )
        }
    }
}
