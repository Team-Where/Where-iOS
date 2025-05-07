//
//  Bundle.swift
//  Where
//
//  Created by Swain Yun on 5/8/25.
//

import Foundation

extension Bundle {
    typealias Key = String
    
    private enum FetchingAPIKeyError: Error, CustomDebugStringConvertible {
        case fileNotFound, keyNotFound
        
        var debugDescription: String {
            switch self {
            case .fileNotFound: "번들에서 해당 파일을 찾을 수 없음"
            case .keyNotFound: "번들에서 해당 키를 찾을 수 없음"
            }
        }
    }
    
    static private func fetchKey(_ provider: AuthentificationProvider) -> Result<Key, FetchingAPIKeyError> {
        // Bundle 검색에 필요한 키
        let infoDictionaryKey: String? = {
            switch provider {
            case .apple, .custom: nil
            case .kakao: "KAKAO_NATIVE_APP_KEY"
            case .naver: "NAVER_NATIVE_APP_KEY"
            }
        }()
        
        guard let infoDictionaryKey = infoDictionaryKey,
              let key = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
        else { return .failure(.keyNotFound) }
        
        return .success(key)
    }
    
    static func fetchKey(provider: AuthentificationProvider) -> String? {
        switch fetchKey(provider) {
        case .success(let key):
            return key
        case .failure(let error):
            print(error.debugDescription)
            return nil
        }
    }
}
