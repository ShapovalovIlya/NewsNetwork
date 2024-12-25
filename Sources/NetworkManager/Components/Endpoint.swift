//
//  Endpoint.swift
//
//
//  Created by Илья Шаповалов on 21.03.2024.
//

import Foundation
import Monad
import SwiftFP

typealias Endpoint = Monad<URLComponents>

extension Endpoint {
    @usableFromInline
    enum Scheme: String { case http, https }
    
    init() { self.init(URLComponents()) }
    
    @inlinable
    func scheme(_ s: Scheme) -> Self {
        mutate { $0.scheme = s.rawValue }
    }
    
    @inlinable
    func addPath(_ p: String) -> Self {
        mutate { $0.path = $0.path.appending("/").appending(p) }
    }
    
    @inlinable
    func queryItems(
        @QueryItemBuilder _ build: () -> [URLQueryItem]
    ) -> Self {
        mutate { components in
            if components.queryItems == nil {
                components.queryItems = build()
                return
            }
            components.queryItems?.append(contentsOf: build())
        }
    }
    
    @inlinable
    func addQuery(_ item: URLQueryItem) -> Self {
        self.queryItems { item }
    }
    
    @inlinable
    func reduceToUrl(
        _ throwing: (URLComponents) -> Error = { _ in URLError(.badURL) }
    ) -> Result<URL, Error> {
        reduce { components in
            Result {
                if let url = components.url { return url }
                throw throwing(components)
            }
        }
    }
}

@usableFromInline
@resultBuilder
enum QueryItemBuilder {
    @usableFromInline
    typealias QueryCollection = Collection<URLQueryItem>
    
    @inlinable
    static func buildBlock(_ components: URLQueryItem...) -> some QueryCollection {
        components
    }
    
    @inlinable
    static func buildOptional(_ component: URLQueryItem?) -> any QueryCollection {
        if let component {
            return CollectionOfOne(component)
        }
        return EmptyCollection()
    }
        
    @inlinable
    static func buildFinalResult(_ component: some QueryCollection) -> [URLQueryItem] {
        Array(component)
    }
}
