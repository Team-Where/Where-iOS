//
//  SelectionTab.swift
//  Where
//
//  Created by Swain Yun on 3/24/25.
//

import SwiftUI

protocol SelectionTabItem: Identifiable {
    associatedtype Content: View
    
    var title: String { get }
    
    @ViewBuilder func view() -> Content
}

struct SelectionTab<TabItem: SelectionTabItem>: View {
    @State private var selectedTab: Int = .zero
    
    private let selection: [TabItem]
    
    init(selection: [TabItem]) {
        self.selection = selection
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(selection.indices, id: \.self) { index in
                    tab(index)
                }
            }
            
            selection[selectedTab].view()
        }
    }
    
    @ViewBuilder private func tab(_ index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            let item = selection[index]
            
            VStack {
                Text(item.title)
                    .whereFont(selectedTab == index ? .body16semibold : .body16regular)
                
                Rectangle()
                    .frame(height: 2)
            }
            .foregroundStyle(selectedTab == index ? Color(hex: 0x1F2937) : Color(hex: 0xE5E7EB))
        }
    }
}
