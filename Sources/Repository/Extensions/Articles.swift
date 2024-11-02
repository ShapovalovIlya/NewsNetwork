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
            let author = obj.author,
            let title = obj.title,
            let description = obj.snippet,
            let url = obj.url,
            let urlToImage = obj.urlToImage,
            let publishedAt = obj.publishedAt,
            let content = obj.content
        else {
            throw NewsError.persistenceError("Property missing. Obj: \(ArticleEntity.className())")
        }
        self.init(
            source: try Source(entity),
            author: author,
            title: title,
            description: description,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
    
    
}
