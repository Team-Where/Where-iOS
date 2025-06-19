//
//  SharedPlaceDataSource.swift
//  Where
//
//  Created by Swain Yun on 6/19/25.
//

import Foundation

/// 외부 앱으로부터 공유받은 장소 정보 자료구조 입니다.
struct SharedPlaceDataSource {
    let name: String
    let address: String?
    let urlString: String?
    
    var sourceApp: MapAppScheme {
        if let _ = address, urlString == nil {
            return .navermap
        } else if let _ = urlString, address == nil {
            return .kakaomap
        } else {
            // 둘다 nil일 경우는 보통 발생하지 않으나 위험할 수 있으니 추후 개선할 것
            return .kakaomap
        }
    }
}
