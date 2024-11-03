//
//  ResponseModel.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//

import Foundation

public struct ResponseModel: Decodable {
    public let status: String
    
    /// The total number of results available for your request.
    /// Only a limited number are shown at a time though,
    /// so use the page parameter in your requests to page through them.
    public let totalResults: Int
    
    /// The results of the request.
    public let articles: [Article]
}
