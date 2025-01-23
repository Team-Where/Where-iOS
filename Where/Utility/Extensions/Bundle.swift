//
//  Bundle.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
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
        guard let key = Bundle.main.object(forInfoDictionaryKey: provider.infoDictionaryKey) as? String else { return .failure(.keyNotFound) }
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
