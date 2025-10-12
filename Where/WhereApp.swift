//
//  WhereApp.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI
import Swinject
import KakaoSDKCommon

@main
struct WhereApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
        self.appDelegate.configure(resolver: resolver)
        configureKakaoAPI()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(resolver: resolver)
            }
            .preferredColorScheme(.light)
        }
    }
    
    private func configureKakaoAPI() {
        guard let key = Bundle.fetchKey(provider: .kakao) else { fatalError("카카오SDK 초기화 실패: 잘못된 앱키") }
        KakaoSDK.initSDK(appKey: key)
    }
}
