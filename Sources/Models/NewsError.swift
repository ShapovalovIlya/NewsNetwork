//
//  File.swift
//  
//
//  Created by Келлер Дмитрий on 26.03.2024.
//

import Foundation

public enum NewsError: Error {
    case badResponse(URLResponse)
    case badRequest
    case unauthorized
    case tooManyRequests
    case serverError
    case noData
    case decodingError(DecodingError)
    case badUrl(_ components: URLComponents)
    case apiKeyMissing
    case unknown(Error)
    case persistenceError(String)
    
    public init?(statusCode: Int) {
        switch statusCode {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 429: self = .tooManyRequests
        case 500: self = .serverError
        default: return nil
        }
    }
    
    public static func map(_ error: Error) -> NewsError {
        switch error {
        case let newsError as NewsError:
            return newsError
            
        case let decoding as DecodingError:
            return .decodingError(decoding)
            
        default:
            return .unknown(error)
        }
    }
    
}

//extension NewsError: LocalizedError {
//    public var errorDescription: String? {
//        
//    }
//}

