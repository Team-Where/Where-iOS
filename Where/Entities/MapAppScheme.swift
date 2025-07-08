//
//  MapAppScheme.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import UIKit

/// URL Schemes 및 관련 정보를 정의합니다.
enum MapAppScheme {
    /// 카카오맵
    case kakaomap
    /// 네이버지도
    case navermap
    
    private var identifier: String? { Bundle.main.bundleIdentifier }
    
    private var baseURLString: String {
        switch self {
        case .kakaomap: "kakaomap://"
        case .navermap: "nmap://"
        }
    }
    
    private func isAppInstalled(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
    
    func openURL() -> URL? {
        switch self {
        case .kakaomap:
            guard let deeplink = URL(string: "\(baseURLString)open?page=placeSearch"),
                  let appstoreLink = URL(string: "https://apps.apple.com/app/id304608425")
            else { return nil }
            
            guard isAppInstalled(deeplink) else { return appstoreLink }
            return deeplink
        case .navermap:
            guard let identifier = identifier,
                  let deeplink = URL(string: "\(baseURLString)map?&appname=\(identifier)"),
                  let appstoreLink = URL(string: "https://apps.apple.com/app/id311867728")
            else { return nil }
            
            guard isAppInstalled(deeplink) else { return appstoreLink }
            return deeplink
        }
    }
}
