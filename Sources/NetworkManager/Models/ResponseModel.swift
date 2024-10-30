//
//  ResponseModel.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//

import Foundation

struct ResponseModel: Decodable {
    let status: String
    
    /// The total number of results available for your request.
    /// Only a limited number are shown at a time though,
    /// so use the page parameter in your requests to page through them.
    let totalResult: Int
    
    /// The results of the request.
    let articles: [Article]
}
