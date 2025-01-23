//
//  TokenStorage.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation
import Security

protocol TokenManagable {
    typealias Query = [String: Any]
    typealias Key = UInt64
    
    func store(_ tokens: Data, by key: Key) throws
    func fetch(by key: Key) throws -> Data
    func delete(by key: Key) throws
}

private enum TokenStorageError: Error {
    case unknown
    case failedFindToken
    case failedCasting
}

final class TokenStorage {
    private let bundleIdentifier: String? = Bundle.main.bundleIdentifier
    
    init() {
        
    }
    
    private func _create(_ data: Data, in query: Query) throws {
        var query = query
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        try check(status, which: #function)
    }
    
    private func _read(_ query: Query) throws -> CFTypeRef? {
        var query = query
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var dataTypeRef: CFTypeRef? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        try check(status, which: #function)
        
        return dataTypeRef
    }
    
    private func _update(_ data: Data, in query: Query) throws {
        let queryToUpdate: Query = [kSecValueData as String: data]

        let status = SecItemUpdate(query as CFDictionary, queryToUpdate as CFDictionary)
        try check(status, which: #function)
    }
    
    private func _delete(_ query: Query) throws {
        let status = SecItemDelete(query as CFDictionary)
        try check(status, which: #function)
    }
}

// MARK: Utility Methods for CRUD
extension TokenStorage {
    private func makeQuery(by key: Key) throws -> Query {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: bundleIdentifier ?? "",
            kSecAttrAccount as String: key
        ]
    }
    
    private func check(_ status: OSStatus, which function: String) throws {
        guard status != noErr else { return }
        
        let errorMessage = SecCopyErrorMessageString(status, nil) as String? ?? "\(TokenStorageError.unknown)"
        print("Error in \(function): \(errorMessage)")
        
        if status == errSecItemNotFound {
            throw TokenStorageError.failedFindToken
        } else {
            throw TokenStorageError.unknown
        }
    }
    
    private func convert(_ ref: CFTypeRef?) throws -> Data {
        guard let data = ref else {
            throw TokenStorageError.failedFindToken
        }
        
        guard let data = data as? Data else {
            throw TokenStorageError.failedCasting
        }
        
        return data
    }
}

// MARK: TokenStorage Conformation
extension TokenStorage: TokenManagable {
    func store(_ tokens: Data, by key: Key) throws {
        let query = try makeQuery(by: key)
        
        do {
            if let _ =  try _read(query) {
                try _update(tokens, in: query)
            }
        } catch TokenStorageError.failedFindToken {
            try _create(tokens, in: query)
        }
    }
    
    func fetch(by key: Key) throws -> Data {
        let query = try makeQuery(by: key)
        let reference = try _read(query)
        let data = try convert(reference)
        return data
    }
    
    func delete(by key: Key) throws {
        let query = try makeQuery(by: key)
        try _delete(query)
    }
}
