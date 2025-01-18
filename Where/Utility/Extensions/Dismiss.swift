//
//  Dismiss.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

extension View {
    var dismiss: DismissAction {
        @Environment(\.dismiss) var dismiss
        return dismiss
    }
}
