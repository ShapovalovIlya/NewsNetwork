//
//  Articles.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 01.11.2024.
//

import Foundation
import Models
import CoreData
import PersistenceManager

extension ArticleEntity {
    @inlinable func copy(_ article: Article) {
        self.author = article.author
        self.title = article.title
        self.snippet = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
        self.content = article.content
    }
    
    @inlinable
    static func map(_ context: NSManagedObjectContext) -> (Article) -> ArticleEntity {
        { article in
            let entity = ArticleEntity(context: context)
            entity.sourceEntity = SourceEntity(context: context)
            entity.sourceEntity?.copy(article.source)
            entity.copy(article)
            return entity
        }
    }
}

extension Article {
    init(_ obj: ArticleEntity) throws {
        guard
            let entity = obj.sourceEntity,
            let title = obj.title,
            let url = obj.url,
            let publishedAt = obj.publishedAt
        else {
            throw NewsError.persistenceError("Property missing. Obj: \(obj)")
        }
        self.init(
            source: try Source(entity),
            author: obj.author,
            title: title,
            description: obj.snippet,
            url: url,
            urlToImage: obj.urlToImage,
            publishedAt: publishedAt,
            content: obj.content
        )
    }
    
    
}
