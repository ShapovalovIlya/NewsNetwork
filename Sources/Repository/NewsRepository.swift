//
//  NewsRepository.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//

import Foundation
import NetworkManager
import PersistenceManager
import CoreData
public import Models

public let DefaultApiKey = "6b77ceed56dc45b8b67542940b8a3409"

/// Сущность для взаимодействия с NewsApi.
///
/// Для корректной работы, после загрузки приложения нужно вызвать метод `register(apiKey: String)`
public final class NewsRepository: @unchecked Sendable {
    public static let shared = NewsRepository()
    
    private let lock = NSRecursiveLock()
    private let network = NetworkManager()
    private let persistence: ArticlesProvider
    
    private init() {
        let desc = NSPersistentStoreDescription()
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true
        persistence = ArticlesProvider(descriptions: [desc])
    }
    
    public func register(apiKey: String = DefaultApiKey) async {
        await network.register(key: apiKey)
    }
    
    
    /// Поиск новостей по ключевой строке.
    ///
    /// Tips:
    /// - Оберните фразы кавычками (") для точного соответствия.
    /// - Добавьте к началу слова или фразы, которые должны появиться, со знаком +. Например: +биткойн
    /// - В начале слов, которые не должны появляться, используйте символ -. Например: -биткойн
    /// - В качестве альтернативы вы можете использовать ключевые слова AND / OR / NOT и при необходимости сгруппировать их с помощью круглых скобок.
    /// Например: криптовалюта И (эфириум ИЛИ лайткойн), НЕ биткойн.
    ///
    /// - Parameters:
    ///   - query: Ключевое слово или фраза, пристсвующая в статье.
    ///            Максимальная длинна строки - 500 символов
    ///   - page: Страница списка новостей
    ///   - size: Размер (кол-во объектов) в одной странице
    /// - Returns: Список новостей или ошибка, возникшая в процессе запроса.
    public func search(
        _ query: String,
        page: Int = 1,
        size: Int = 100
    ) async -> Result<[Article], NewsError> {
        await network.search(query, page: page, size: size)
    }
    
    /// Поиск популярный новостей в категории.
    ///
    /// Возможные категории см. `enum` ``Category``
    ///
    /// - Parameters:
    ///   - category: Категория поиска новостей.
    ///   - page: Страница списка новостей
    ///   - size: Размер (кол-во объектов) в одной странице
    /// - Returns: Список новостей или ошибка, возникшая в процессе запроса.
    public func getPopular(
        _ category: Models.Category,
        page: Int = 1,
        size: Int = 100
    ) async -> Result<[Article], NewsError> {
        await network.getPopular(category, page: page, size: size)
    }
    
    /// Сохранить в БД выбранные объекты
    /// - Parameter articles: экземпляр или коллекция объектов
    /// - Returns: коллекция сохраненных объектов, либо ошибка, возникшая в процессе
    @discardableResult
    public func save(articles: Article...) async -> Result<[Article], NewsError> {
        await persistence.write { context in
            _ = articles.map(ArticleEntity.map(context))
        }
        .map { articles }
        .mapError(NewsError.map)
    }
    
    /// Удалить из БД выбранные объекты
    /// - Parameter articles: экземпляр или коллекция объектов
    /// - Returns: коллекция удаленных объектов, либо ошибка, возникшая в процессе
    @discardableResult
    public func delete(articles: Article...) async -> Result<[Article], NewsError> {
        await persistence.write { context in
            let request = ArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url IN %@", articles.map(\.url))
            let result = try context.fetch(request)
            result.forEach(context.delete)
            let deleted = result.compactMap(\.url)
            return articles.filter { deleted.contains($0.url) }
        }
        .mapError(NewsError.map)
    }
    
    /// Получить из БД все сохраненные объекты
    /// - Returns: коллекция объектов, либо ошибка, возникшая в процессе
    @discardableResult
    public func loadArticles() async -> Result<[Article], NewsError> {
        await persistence.fetch().tryMap { entities in
            try entities.map(Article.init)
        }
        .mapError(NewsError.map)
    }
}

private extension NewsRepository {
    func mutate(_ body: (NewsRepository) -> Void) {
        lock.withLock { body(self) }
    }
}
