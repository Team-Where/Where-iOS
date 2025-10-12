//
//  FlowLayout.swift
//  Where
//
//  Created by Swain Yun on 3/21/25.
//

import SwiftUI

struct FlowLayout: Layout {
    var alignment: Alignment
    var spacing: CGFloat
    
    init(alignment: Alignment, spacing: CGFloat = 20) {
        self.alignment = alignment
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0 // 제안된 최대 너비
        var totalHeight: CGFloat = 0       // 전체 높이
        var currentRowWidth: CGFloat = 0   // 현재 줄의 너비
        var currentRowHeight: CGFloat = 0  // 현재 줄의 높이

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentRowWidth + size.width + (currentRowWidth > 0 ? spacing : 0) <= maxWidth {
                currentRowWidth += size.width + (currentRowWidth > 0 ? spacing : 0)
                currentRowHeight = max(currentRowHeight, size.height)
            } else {
                totalHeight += currentRowHeight + (totalHeight > 0 ? spacing : 0)
                currentRowWidth = size.width
                currentRowHeight = size.height
            }
        }

        totalHeight += currentRowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX // 현재 x 좌표
        var y = bounds.minY // 현재 y 좌표
        var currentRowHeight: CGFloat = 0 // 현재 줄의 높이

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let subviewProposal = ProposedViewSize(width: size.width, height: size.height)

            if x + size.width <= bounds.maxX {
                subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: subviewProposal)
                x += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            } else {
                x = bounds.minX
                y += currentRowHeight + spacing
                subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: subviewProposal)
                x += size.width + spacing
                currentRowHeight = size.height
            }
        }
    }
}
