//
//  Request.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 23.10.2024.
//

import Foundation
import Readers

public typealias Request = Reader<URL, URLRequest>

extension Request {
    private func mutate(_ transform: @escaping (inout URLRequest) -> Void) -> Self {
        map { request in
            var request = request
            transform(&request)
            return request
        }
    }
    
    func method(_ m: HTTPMethod) -> Self {
        self.httpMethod(m.rawValue)
    }
    
    func addHeader(_ value: String, field: String) -> Self {
        mutate { $0.addValue(value, forHTTPHeaderField: field) }
    }
    
    static func new() -> Self { Request { URLRequest(url: $0) } }
    static var get: Self { Self.new().method(.get) }
}

extension Request {
    @usableFromInline
    enum HTTPMethod: String {
        case get
        case post
        case put
        case delete
        case head
    }
}
