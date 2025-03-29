//
//  WhereApp.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI

@main
struct WhereApp: App {
    @AppStorage(AppStorageKey.isOnboardingNeeded) private var isOnboardingNeeded: Bool = true
    @State private var isOnboardingViewPresented: Bool = false
    @StateObject private var auth = AuthentificationCore(networkService: NetworkService())
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TabBarView()
                    .navigationDestination(isPresented: $isOnboardingViewPresented) {
                        OnboardingView()
                    }
                    .onAppear {
                        isOnboardingViewPresented = isOnboardingNeeded
                    }
            }
            .environmentObject(auth)
        }
    }
}
