//
//  CoreDataRepository.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 31.10.2024.
//

import Foundation
import CoreData
import SwiftFP

struct CoreDataRepository<Entity: NSManagedObject> {
    let context: NSManagedObjectContext
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    @inlinable
    func fetch(
        predicate: NSPredicate? = nil,
        descriptors: [NSSortDescriptor] = []
    ) async -> Result<[Entity], Error> {
        await Result {
            try await context.perform {
                let request = Entity.fetchRequest()
                request.predicate = predicate
                request.sortDescriptors = descriptors
                return try context.fetch(request) as! [Entity]
            }
        }
    }
    
    @inlinable
    func write<R>(
        _ body: @escaping (NSManagedObjectContext) throws -> R = { _ in }
    ) async -> Result<R, Error> {
        await Result {
            try await context.perform {
                let result = try body(context)
                guard context.hasChanges else { return result }
                try context.save()
                return result
            }
        }
        .mapError { context.rollback(); return $0 }
    }
    
    @inlinable
    func delete(_ entities: [Entity]) async -> Result<[Entity], Error> {
        await Result {
            try await context.perform {
                entities.forEach(context.delete)
                try context.save()
                return entities
            }
        }
    }
}
