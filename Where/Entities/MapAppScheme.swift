//
//  MapAppScheme.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import UIKit

/// URL Schemes 및 관련 정보를 정의합니다.
enum MapAppScheme {
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
    
    func isAppInstalled() -> Bool {
        guard let url = URL(string: baseURLString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func openURL() -> URL? {
        switch self {
        case .kakaomap:
            return URL(string: "\(baseURLString)open?page=placeSearch")
        case .navermap:
            guard let identifier = identifier else { return nil }
            return URL(string: "\(baseURLString)map?&appname=\(identifier)")
        }
    }
}
