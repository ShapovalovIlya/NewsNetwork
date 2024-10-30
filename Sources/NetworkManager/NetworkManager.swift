//
//  NetworkManager.swift
//  NewsToDay
//
//  Created by Келлер Дмитрий on 17.03.2024.
//

import Foundation
import SwiftFP
import CoreImage

actor NetworkManager {
    public typealias NetworkTask = @Sendable (URLRequest) async throws -> (Data, URLResponse)
    
    private var apiKey: String?
    private let decoder: JSONDecoder
    private let fetcher: NetworkTask
    
    //MARK: - init(_:)
    init(fetcher: @escaping NetworkTask = URLSession.shared.data) {
        self.fetcher = fetcher
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    //MARK: - Public methods
    func register(key: String) async {
        self.apiKey = key
    }
    
    func search(_ query: String, page: Int, size: Int) async -> Result<[Article], NewsError> {
        await perform(.search(query, page: page, size: size))
            .map(\.articles)
    }
    
    func getPopular(_ category: Category, page: Int, size: Int) async -> Result<[Article], NewsError> {
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
    
    func injectApi(key: String?) -> (Request) throws -> Request {
        { request in
            guard let key else { throw NewsError.apiKeyMissing }
            return request.addHeader(key, field: "X-Api-Key")
        }
    }
    
    func perform(_ endpoint: Endpoint) async -> Result<ResponseModel, NewsError> {
        await endpoint
            .reduceToUrl(NewsError.badUrl)
            .map(Request.new)
            .map { $0.method(.get) }
            .tryMap(injectApi(key: apiKey))
            .map(\.wrapped)
            .asyncTryMap(fetcher)
            .tryMap(unwrap(response:))
            .decodeJSON(ResponseModel.self, decoder: decoder)
            .mapError(NewsError.map)
    }
}
