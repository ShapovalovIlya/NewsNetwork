//
//  Article.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//

import Foundation

public struct Article: Decodable, Sendable {
    
    /// The identifier id and a display name name for the source this article came from.
    public let source: Source
    
    /// The author of the article
    public let author: String
    
    /// The headline or title of the article.
    public let title: String
    
    /// A description or snippet from the article.
    public let description: String
    
    /// The direct URL to the article.
    public let url: URL
    
    /// The URL to a relevant image for the article.
    public let urlToImage: URL
    
    /// The date and time that the article was published, in UTC (+000)
    public let publishedAt: Date
    
    /// The unformatted content of the article, where available. This is truncated to 200 chars.
    public let content: String
}
