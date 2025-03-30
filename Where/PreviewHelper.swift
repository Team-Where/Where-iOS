//
//  PreviewHelper.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import SwiftUI
import Swinject

@MainActor
final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let resolver: Resolver
    
    private init() {
        let assembler = Assembler(
            [
                ServiceAssembly(),
                CoreAssembly(),
                ViewModelAssembly()
            ],
            container: Container()
        )
        self.resolver = assembler.resolver
    }
}
