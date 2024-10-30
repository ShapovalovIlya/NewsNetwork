//
//  NetworkManager.swift
//  NewsToDay
//
//  Created by Келлер Дмитрий on 17.03.2024.
//

import Foundation
import SwiftFP
import CoreImage

final class NetworkManager: Sendable {
    public typealias NetworkTask = @Sendable (URLRequest) async throws -> (Data, URLResponse)
    public typealias Keygen = @Sendable () -> String
    
    let apiKey: Keygen
    let decoder = JSONDecoder()
    let fetcher: NetworkTask
    
    //MARK: - init(_:)
    private init(
        fetcher: @escaping NetworkTask = URLSession.shared.data,
        apiKey: @escaping Keygen
    ) {
        self.fetcher = fetcher
        self.apiKey = apiKey
        decoder.dateDecodingStrategy = .iso8601
    }
    
    //MARK: - Public methods
    func search(_ query: String, page: Int, size: Int) async -> Result<[Article], NewsError> {
        await perform(.search(query, page: page, size: size))
            .map(\.articles)
    }
    
    func getPopular(for category: Category, page: Int, size: Int) async -> Result<[Article], NewsError> {
        await perform(.popular(category))
            .map(\.articles)
    }
    
    
}

private extension NetworkManager {
    func unwrap(response: (data: Data, urlResponse: URLResponse)) throws -> Data {
        guard let httpResponse = response.urlResponse as? HTTPURLResponse else {
            throw NewsError.badResponse(response.urlResponse)
        }
        if let error = NewsError(statusCode: httpResponse.statusCode) {
            throw error
        }
        return response.data
    }
    
    func perform(_ endpoint: Endpoint) async -> Result<ResponseModel, NewsError> {
        await endpoint
            .reduceToUrl(NewsError.badUrl)
            .map(Request.new)
            .map { request in
                request
                    .method(.get)
                    .addHeader(apiKey(), field: "X-Api-Key")
            }
            .map(\.wrapped)
            .asyncTryMap(fetcher)
            .tryMap(unwrap(response:))
            .decodeJSON(ResponseModel.self, decoder: decoder)
            .mapError(NewsError.map)
    }
}
