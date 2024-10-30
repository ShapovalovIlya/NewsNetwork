//
//  Request.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 23.10.2024.
//

import Foundation
import Monad

public typealias Request = Monad<URLRequest>

extension Request {
    @inlinable
    static func new(_ url: URL) -> Self {
        Request(URLRequest(url: url))
    }
    
    @inlinable
    func method(_ m: HTTPMethod) -> Self {
        mutate { $0.httpMethod = m.rawValue }
    }
    
    @inlinable
    func addHeader(_ value: String, field: String) -> Self {
        mutate { $0.addValue(value, forHTTPHeaderField: field) }
    }
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
