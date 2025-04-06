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
        let diskCacheCapacity: Int = 50 * 1024 * 1024 // 50MB
        let memoryCacheCapacity: Int = 100 * 1024 * 1024 // 100MB
        URLCache.shared.diskCapacity = diskCacheCapacity
        URLCache.shared.memoryCapacity = memoryCacheCapacity
        URLSession.shared.configuration.urlCache = .shared
        
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
