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
    @inlinable
    static func map(_ article: Article) -> ArticleEntity {
        let entity = ArticleEntity()
        let sourceEntity = SourceEntity()
        sourceEntity.id = article.source.id
        sou
        return entity
    }
}
