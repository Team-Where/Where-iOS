//
//  ToolTip.swift
//  Where
//
//  Created by Swain Yun on 2/3/25.
//

import SwiftUI

enum ArrowPosition {
    case topLeading
    case topTrailing
    case top
}

struct ArrowSize {
    let width: CGFloat
    let height: CGFloat
    var size: CGSize { .init(width: width, height: height) }
    
    init(width: CGFloat = 12, height: CGFloat = 8) {
        self.width = width
        self.height = height
    }
    
    init(size: CGSize = CGSize(width: 12, height: 8)) {
        self.width = size.width
        self.height = size.height
    }
}

struct ToolTipConfiguration {
    private struct Constants {
        static let defaultArrowSize: ArrowSize = .init(width: 12, height: 8)
        static let defaultBackgroundColor: Color = .where(.gray800)
        static let defaultCornerRadius: CGFloat = 6
    }
    
    let arrowPosition: ArrowPosition
    let arrowSize: ArrowSize
    let backgroundColor: Color
    let cornerRadius: CGFloat
    
    init(
        arrowPosition: ArrowPosition,
        arrowSize: ArrowSize? = nil,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.arrowPosition = arrowPosition
        self.arrowSize = arrowSize ?? Constants.defaultArrowSize
        self.backgroundColor = backgroundColor ?? Constants.defaultBackgroundColor
        self.cornerRadius = cornerRadius ?? Constants.defaultCornerRadius
    }
}

struct ToolTipView<Content:View, Label: View>: View {
    @State private var size: CGSize = .zero
    @Binding var isPresented: Bool
 
    private let content: Content
    private let label: Label
    private let configuration: ToolTipConfiguration
    
    init(
        _ isPresented: Binding<Bool>,
        configuration: ToolTipConfiguration,
        content: Content,
        label: @escaping () -> Label
    ) {
        self._isPresented = isPresented
        self.configuration = configuration
        self.content = content
        self.label = label()
    }
    
    var body: some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        GeometryReader { proxy in
                            toolTipContent(configuration.arrowPosition, label: label)
                                .fixedSize()
                                .onGeometryChange(for: CGSize.self) { proxy in
                                    proxy.size
                                } action: { newValue in
                                    self.size = newValue
                                }
                                .position(getToolTipPosition(proxy))
                        }
                    }
                }
            )
    }
    
    private var horizontalAlignment: HorizontalAlignment {
        switch configuration.arrowPosition {
        case .topLeading: .leading
        case .topTrailing: .trailing
        case .top: .center
        }
    }
    
    @ViewBuilder private func toolTipContent(_ arrowPosition: ArrowPosition, label: Label) -> some View {
        VStack(alignment: horizontalAlignment, spacing: 0) {
            toolTipArrow(arrowPosition)
            toolTipLabel(label: label)
        }
    }
    
    @ViewBuilder private func toolTipArrow(_ arrowPosition: ArrowPosition) -> some View {
        Triangle()
            .fill(configuration.backgroundColor)
            .frame(width: configuration.arrowSize.width, height: configuration.arrowSize.height)
            .padding(.leading, horizontalAlignment == .leading ? 10 : 0)
            .padding(.trailing, horizontalAlignment == .trailing ? 10 : 0)
    }
    
    @ViewBuilder private func toolTipLabel(label: Label) -> some View {
        label
            .background(configuration.backgroundColor)
            .clipShape(.rect(cornerRadius: configuration.cornerRadius))
    }
    
    private func getToolTipPosition(_ proxy: GeometryProxy) -> CGPoint {
        let targetWidth = proxy.size.width
        let targetHeight = proxy.size.height
        
        switch configuration.arrowPosition {
        case .topLeading:
            return CGPoint(x: targetWidth / 2 + size.width / 2 - 16, y: targetHeight + size.height / 2 + 6)
        case .topTrailing:
            return CGPoint(x: targetWidth / 2 - size.width / 2 + 16, y: targetHeight + size.height / 2 + 6)
        case .top:
            return CGPoint(x: targetWidth / 2, y: targetHeight + size.height / 2 + 6)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
