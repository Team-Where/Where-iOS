//
//  WhereApp.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI

@main
struct WhereApp: App {
    @StateObject private var authentificationService = AuthentificationService(networkService: NetworkService())
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView()
            }
            .environmentObject(authentificationService)
        }
    }
}
