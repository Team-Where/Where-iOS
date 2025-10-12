//
//  SideMenu.swift
//  Where
//
//  Created by Swain Yun on 3/27/25.
//

import SwiftUI

struct SideMenuModifier<SideMenuContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let sideMenuContent: () -> SideMenuContent
    let sideMenuWidthRatio: CGFloat = 0.95
    
    @State private var rootViewSize: CGSize = .zero
    @State private var sideMenuWidth: CGFloat = .zero
    
    init(
        _ isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SideMenuContent
    ) {
        self._isPresented = isPresented
        self.sideMenuContent = content
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newValue in
                    rootViewSize = newValue
                    sideMenuWidth = newValue.width * sideMenuWidthRatio
                }
                .overlay(
                    isPresented ?
                    Color.black.opacity(0.3)
                        .ignoresSafeArea(edges: .top)
                        .onTapGesture {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    : nil
                )
            
            if isPresented {
                sideMenuView()
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
    
    @ViewBuilder private func sideMenuView() -> some View {
        sideMenuContent()
            .frame(width: sideMenuWidth)
            .background(.white)
            .transition(.move(edge: .trailing))
            .zIndex(1)
    }
}

#Preview {
    ContentView(resolver: PreviewHelper.shared.resolver)
}
