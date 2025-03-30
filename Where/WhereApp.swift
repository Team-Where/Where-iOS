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
    @AppStorage(AppStorageKey.isOnboardingNeeded) private var isOnboardingNeeded: Bool = true
    @State private var isOnboardingViewPresented: Bool = false
    @State private var isLoginNeeded: Bool = true
    
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
            NavigationStack {
                TabBarView()
                    .navigationDestination(isPresented: $isOnboardingViewPresented) {
                        OnboardingView()
                    }
                    .fullScreenCover(isPresented: $isLoginNeeded) {
                        LoginView($isLoginNeeded, resolver: resolver)
                    }
                    .onAppear {
                        isOnboardingViewPresented = isOnboardingNeeded
                    }
            }
        }
    }
}
