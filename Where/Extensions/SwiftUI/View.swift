//
//  View.swift
//  Where
//
//  Created by Swain Yun on 5/7/25.
//

import SwiftUI

// MARK: - View+Popup
extension View {
    func popup(
        _ isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(PopupModifier(isPresented, popupContent: content))
    }
}

// MARK: - View+Floater
extension View {
    func floater(
        _ isPresented: Binding<Bool>,
        title: String
    ) -> some View {
        modifier(FloaterModifier<EmptyView>(isPresented, title, nil))
    }

    func floater<Icon: View>(
        _ isPresented: Binding<Bool>,
        title: String,
        @ViewBuilder icon: @escaping () -> Icon
    ) -> some View {
        modifier(FloaterModifier(isPresented, title, icon))
    }

    func floater<Item: FloaterContent, Icon: View>(
        _ item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Icon
    ) -> some View {
        let isPresented = Binding<Bool> { item.wrappedValue != nil } set: { if !$0 { item.wrappedValue = nil } }
        let title = item.wrappedValue?.title ?? String()
        return modifier(FloaterModifier(isPresented, title, { item.wrappedValue.map(content) }))
    }
}

// MARK: - View+ToolTip
extension View {
    func whereTip<Label: View>(
        _ isPresented: Binding<Bool>,
        configuration: ToolTipConfiguration,
        label: @escaping () -> Label
    ) -> some View {
        ToolTipView<Self, Label>(isPresented, configuration: configuration, content: self, label: label)
    }
    
    func whereTip<Label: View>(
        _ isPresented: Binding<Bool>,
        arrowPosition: ArrowPosition,
        arrowSize: ArrowSize? = nil,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        label: @escaping () -> Label
    ) -> some View {
        let configuration = ToolTipConfiguration(arrowPosition: arrowPosition, arrowSize: arrowSize, backgroundColor: backgroundColor, cornerRadius: cornerRadius)
        return ToolTipView(isPresented, configuration: configuration, content: self, label: label)
    }
}

// MARK: - View+Form
extension View {
    func whereForm<ActionButton: View>(_ title: String, @ViewBuilder actionButton: @escaping () -> ActionButton) -> some View {
        modifier(WhereFormModifier(title, actionButton: actionButton()))
    }
}

// MARK: - View+SideMenu
extension View {
    func sideMenu<SideMenuContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SideMenuContent
    ) -> some View {
        modifier(SideMenuModifier<SideMenuContent>(isPresented, content: content))
    }
}

// MARK: - View+WhereFont
extension View {
    func whereFont(_ whereFont: WhereFont) -> some View {
        modifier(WhereFontViewModifier(font: whereFont))
    }
}
