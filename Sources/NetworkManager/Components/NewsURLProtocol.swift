//
//  NewsURLProtocol.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 20.11.2024.
//

import Foundation
import SwiftFP

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

enum ResponseStatus: String, Decodable { case ok, error }

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
            
            let result = await Result { try await session.data(for: request) }
                .tryMap { data, response in
                    switch try decoder.decode(ResponseStatus.self, from: data) {
                    case .ok: return (data, response)
                    case .error:
                        let errModel = try decoder.decode(ResponseError.self, from: data)
                        throw errModel.urlError
                    }
                }
            
            switch result {
            case .success(let success):
                client.urlProtocol(self, didReceive: success.1, cacheStoragePolicy: .allowedInMemoryOnly)
                client.urlProtocol(self, didLoad: success.0)
                
            case .failure(let failure):
                client.urlProtocol(self, didFailWithError: failure)
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

}
