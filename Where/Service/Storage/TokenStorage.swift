//
//  TokenStorage.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation
import Security

protocol TokenStorageProtocol: Sendable {
    typealias Query = [String: Any]
    
    func store(_ tokens: Tokens) throws
    func fetch() throws -> Tokens
    func delete() throws
}

private enum TokenStorageError: Error {
    case unknown
    case failedFindToken
    case failedCasting
}

final class TokenStorage {
    private let bundleIdentifier: String? = Bundle.main.bundleIdentifier
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let key = "com.where.token"
    
    init(
        _ encoder: JSONEncoder,
        _ decoder: JSONDecoder
    ) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    private func _create(_ tokens: Tokens, in query: Query) throws {
        let data = try encoder.encode(tokens)
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
    
    private func _update(_ tokens: Tokens, in query: Query) throws {
        let data = try encoder.encode(tokens)
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
    private func makeQuery() throws -> Query {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: bundleIdentifier ?? "",
            kSecAttrAccount as String: key
        ]
    }
    
    private func check(_ status: OSStatus, which function: String) throws {
        guard status != noErr else { return }
        
        let errorMessage = SecCopyErrorMessageString(status, nil) as String? ?? "\(TokenStorageError.unknown)"
        print("Error occured from TokenStorage: \(function): \(errorMessage)")
        
        if status == errSecItemNotFound {
            throw TokenStorageError.failedFindToken
        } else {
            throw TokenStorageError.unknown
        }
    }
    
    private func convert(_ ref: CFTypeRef?) throws -> Tokens {
        guard let data = ref else {
            throw TokenStorageError.failedFindToken
        }
        
        guard let data = data as? Data else {
            throw TokenStorageError.failedCasting
        }
        let tokens = try decoder.decode(Tokens.self, from: data)
        return tokens
    }
}

// MARK: TokenStorage Conformation
extension TokenStorage: TokenStorageProtocol {
    func store(_ tokens: Tokens) throws {
        let query = try makeQuery()
        
        do {
            if let _ =  try _read(query){
                try _update(tokens, in: query)
            }
        } catch TokenStorageError.failedFindToken {
            try _create(tokens, in: query)
        }
    }
    
    func fetch() throws -> Tokens {
        let query = try makeQuery()
        let reference = try _read(query)
        let data = try convert(reference)
        return data
    }
    
    func delete() throws {
        let query = try makeQuery()
        try _delete(query)
    }
}
