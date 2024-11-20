//
//  NewsURLProtocol.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 20.11.2024.
//

import Foundation
import SwiftFP
import Either

/*
 {
 "status": "error",
 "code": "apiKeyMissing",
 "message": "Your API key is missing. Append this to the URL with the apiKey param, or use the x-api-key HTTP header."
 }
 
 {
 "status": "ok",
 "totalResults": 6581,
 "articles": {}
 }
 */

struct Response: Decodable {
    enum Status: String, Decodable { case ok, error }
    let status: Status
}

struct ResponseError: Decodable {
    let code: String
    let message: String
    
    var urlError: URLError {
        URLError(.badServerResponse, userInfo: [
            "code": code,
            "message": message
        ])
    }
}

public final class NewsURLProtocol: URLProtocol, @unchecked Sendable {
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private var scheduledTask: Task<Void, Error>?
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == Info.handledHost
        && request.httpMethod == Info.handledMethod
    }
    
    public override class func canInit(with task: URLSessionTask) -> Bool {
        task.originalRequest?.url?.host == Info.handledHost
        && task.originalRequest?.httpMethod == Info.handledMethod
    }
    
    //MARK: - startLoading()
    public override func startLoading() {
        guard let client else { return }
        
        scheduledTask = Task { [weak self] in
            guard let self else { return }
            
            _ = await Result { try await session.data(for: request) }
                .tryMap(parseResponse(decoder))
                .either()
                .map { success in
                    client.urlProtocol(self, didReceive: success.1, cacheStoragePolicy: .allowedInMemoryOnly)
                    client.urlProtocol(self, didLoad: success.0)
                }
                .mapRight { error in
                    client.urlProtocol(self, didFailWithError: error)
                }
            
            client.urlProtocolDidFinishLoading(self)
        }
    }
    
    //MARK: - stopLoading
    public override func stopLoading() {
        scheduledTask?.cancel()
    }
    
    
}

private extension NewsURLProtocol {
    enum Info {
        static let handledHost = "newsapi.org"
        static let handledMethod = "GET"
    }

    func parseResponse(
        _ decoder: JSONDecoder
    ) -> (Data, URLResponse) throws -> (Data, URLResponse) {
        { data, response in
            switch try decoder.decode(Response.self, from: data).status {
            case .ok: return (data, response)
            case .error:
                let errModel = try decoder.decode(ResponseError.self, from: data)
                throw errModel.urlError
            }
        }
    }
}
