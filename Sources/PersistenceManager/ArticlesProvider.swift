//
//  ArticlesProvider.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 01.11.2024.
//

import Foundation
import CoreData

public final class ArticlesProvider {
    private let container: NSPersistentContainer
    private let repository: CoreDataRepository<ArticleEntity>
    
    public init(descriptions: [NSPersistentStoreDescription] = []) {
        guard
            let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Unable to initialize CoreData model")
        }
        self.container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        self.container.persistentStoreDescriptions = descriptions
        self.repository = CoreDataRepository(container.viewContext)
        
        self.container.loadPersistentStores { descriptions, error in
            
        }
    }
    
    public func fetch(
        predicate: NSPredicate? = nil,
        descriptors: [NSSortDescriptor] = []
    ) async -> Result<[ArticleEntity], Error> {
        await repository.fetch(predicate: predicate, descriptors: descriptors)
    }
    
    public func save(articles: [ArticleEntity]) async -> Result<[ArticleEntity], Error> {
        await repository.write().map { articles }
    }
    
    public func write<R>(
        _ body: @escaping (NSManagedObjectContext) throws -> R
    ) async -> Result<R, Error> {
        await repository.write(body)
    }
    
    public func delete(
        _ entities: [ArticleEntity]
    ) async -> Result<[ArticleEntity], Error> {
        await repository.delete(entities)
    }
}
