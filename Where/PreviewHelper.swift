//
//  PreviewHelper.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import SwiftUI
import Swinject

final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let resolver: Resolver
    
    private init() {
        let assembler = Assembler(
            [
                AuthAssembly(),
            ],
            container: Container()
        )
        self.resolver = assembler.resolver
    }
}
