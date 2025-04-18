//
//  WhereApp.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI
import Swinject

@main
struct WhereApp: App {
    private let resolver: Swinject.Resolver
    
    init() {
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
    
    var body: some Scene {
        WindowGroup {
            ContentView(resolver: resolver)
        }
    }
}
