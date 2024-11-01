//
//  Endpoints.swift
//
//
//  Created by Илья Шаповалов on 21.03.2024.
//

import Foundation
import Monad
import Models

// api-key: 6b77ceed56dc45b8b67542940b8a3409

extension Endpoint {
    static func new() -> Self {
        Endpoint(URLComponents())
            .scheme(.https)
            .host("newsapi.org")
            .path("/v2")
    }
    
    @inlinable
    func category(_ c: Models.Category) -> Self {
        self.addQuery(URLQueryItem(name: "category", value: c.rawValue))
    }
    
    @inlinable
    func sorting(_ s: Sorting) -> Self {
        self.addQuery(URLQueryItem(name: "sortBy", value: s.rawValue))
    }
    
    @inlinable
    func query(_ q: String) -> Self {
        self.addQuery(URLQueryItem(name: "q", value: q))
    }
    
    @inlinable
    func page(_ p: Int, size: Int) -> Self {
        self.queryItems {
            URLQueryItem(name: "page", value: p.description)
            URLQueryItem(name: "pageSize", value: size.description)
        }
    }
    
    static let everything: Self = Endpoint.new().addPath("everything")
    static let topHeadlines: Self = Endpoint.new().addPath("top-headlines")
    
    static func popular(_ category: Models.Category) -> Self {
        Endpoint
            .topHeadlines
            .category(category)
    }
    
    static func search(_ query: String, page: Int, size: Int) -> Self {
        everything
            .query(query)
            .page(page, size: size)
    }
}
