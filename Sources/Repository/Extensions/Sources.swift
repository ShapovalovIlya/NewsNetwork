//
//  Sources.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 01.11.2024.
//

import Foundation
import Models
import CoreData
import PersistenceManager
import Readers

extension SourceEntity {
    @inlinable func copy(_ source: Source) {
        self.id = source.id
        self.name = source.name
    }
    
    @inlinable
    static func map(_ context: NSManagedObjectContext) -> (Source) -> SourceEntity {
        { source in
            let entity = SourceEntity(context: context)
            entity.copy(source)
            return entity
        }
    }
    
    @inlinable
    static func make(
        from context: NSManagedObjectContext
    ) -> Reader<Source, SourceEntity> {
        Reader(Self.map(context))
    }
}

extension Source {
    init(_ obj: SourceEntity) throws {
        guard let name = obj.name else {
            throw NewsError.persistenceError("Property missing. Obj: \(obj)")
        }
        self.init(id: obj.id, name: name)
    }
}
