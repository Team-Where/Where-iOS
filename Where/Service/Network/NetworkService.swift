//
//  NetworkService.swift
//  Where
//
//  Created by Swain Yun on 1/26/25.
//

import Foundation

protocol URLRequestBuildable {
    func urlRequest() throws -> URLRequest
}

protocol NetworkServiceProtocol {
    func data<E: URLRequestBuildable>(_ endpoint: E) async throws -> Data
}

enum NetworkServiceError: Error {
    case invalidURL
    case requestFailed
    case badResponse(statusCode: Int)
}

final class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: NetworkServiceProtocol Conformation
extension NetworkService: NetworkServiceProtocol {
    func data<E: URLRequestBuildable>(_ endpoint: E) async throws -> Data {
        guard let urlRequest = try? endpoint.urlRequest() else {
            throw NetworkServiceError.invalidURL
        }
        
        guard let (data, response) = try? await session.data(for: urlRequest),
              let httpResponse = response as? HTTPURLResponse
        else {
            throw NetworkServiceError.requestFailed
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkServiceError.badResponse(statusCode: httpResponse.statusCode)
        }
        
        // TODO: 헤더 전처리 로직 필요
        let header = httpResponse.allHeaderFields as? [String: String] ?? [:]
        
        return data
    }
}
