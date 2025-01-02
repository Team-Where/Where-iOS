//
//  SearchBar.swift
//  Where
//
//  Created by Swain Yun on 1/2/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchingText: String
    
    private var isFocused: FocusState<Bool>.Binding
    private let titleKey: String
    private let iconName: String
    
    init(
        _ prompt: String,
        text: Binding<String>,
        _ isFocused: FocusState<Bool>.Binding,
        iconName: String = "magnifyingglass"
    ) {
        self.titleKey = prompt
        self._searchingText = text
        self.isFocused = isFocused
        self.iconName = iconName
    }
    
    var body: some View {
        HStack {
            icon
            
            textFieldArea
            
            if searchingText.isEmpty == false {
                removeButton
            }
        }
        .padding()
        .whereFont(.body16regular)
        .background(Color(hex: 0xF3F4F6))
        .clipShape(.rect(cornerRadius: 12))
    }
    
    private var textFieldArea: some View {
        TextField(titleKey, text: $searchingText)
            .focused(isFocused)
    }
    
    private var icon: some View {
        Image(systemName: iconName)
            .foregroundStyle(Color(hex: 0x6B7280))
    }
    
    private var removeButton: some View {
        Button {
            searchingText.removeAll()
            isFocused.wrappedValue = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(Color(hex: 0x9CA3AF))
        }
    }
}
