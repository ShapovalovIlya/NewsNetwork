//
//  NetworkManager.swift
//  NewsToDay
//
//  Created by Келлер Дмитрий on 17.03.2024.
//

import Foundation
import SwiftFP
import Models

public actor NetworkManager {
    public typealias NetworkTask = @Sendable (URLRequest) async -> Result<(data: Data, response: URLResponse), Error>
    
    private let decoder: JSONDecoder
    private let fetcher: NetworkTask
    
    //MARK: - init(_:)
    public init(fetcher: @escaping NetworkTask) {
        self.fetcher = fetcher
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    //MARK: - Public methods
    public func search(_ query: String, page: Int, size: Int) async -> Result<[Article], NewsError> {
        await perform(.search(query, page: page, size: size))
            .map(\.articles)
    }
    
    public func getPopular(_ category: Models.Category, page: Int, size: Int) async -> Result<[Article], NewsError> {
        await perform(.popular(category))
            .map(\.articles)
    }
    
    
}

private extension NetworkManager {
    func unwrapResponse(
        data: Data,
        response: URLResponse
    ) -> Result<Data, Error> {
        Result {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.badResponse(response)
            }
            if let error = NewsError(statusCode: httpResponse.statusCode) {
                throw error
            }
            return data
        }
    }
    
    func perform(_ endpoint: Endpoint) async -> Result<ResponseModel, NewsError> {
        await endpoint
            .reduceToUrl(NewsError.badUrl)
            .map(Request.get.apply)
            .asyncFlatMap(fetcher)
            .flatMap(unwrapResponse)
            .decodeJSON(ResponseModel.self, decoder: decoder)
            .mapError(NewsError.map)
    }
}
