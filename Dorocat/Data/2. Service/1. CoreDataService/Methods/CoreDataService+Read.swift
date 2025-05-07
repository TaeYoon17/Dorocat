//
//  CoredataService+Read.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation
import CoreData

extension CoreDataService {
    // MARK: - Public Methods
    func findItemByID<Model>(
        _ id: String,
        type: Model.Type,
        entityKey: CoreConstants.Label,
        idKey: String = "id"
    ) async -> Result<Model, CoreError> {
        await performFetch(entityKey: entityKey) {
            try await findItemByEntityConvertible(
                type: TimerRecordItemEntity.self,
                id,
                entityDescriptionKey: entityKey
            )
        }
    }
    
    func findItemsByIDs<Model>(
        _ ids: [String],
        type: Model.Type,
        entityKey: CoreConstants.Label,
        idKey: String = "id"
    ) async -> Result<[Model], CoreError> {
        await performFetch(entityKey: entityKey) {
            try await findItemsByEntityConvertible(
                type: TimerRecordItemEntity.self,
                ids,
                entityDescriptionKey: entityKey
            )
        }
    }
    
    func findAllItems<Model>(
        type: Model.Type,
        entityKey: CoreConstants.Label
    ) async -> Result<[Model], CoreError> {
        await performFetch(entityKey: entityKey) {
            try await findAllItemByEntityConvertible(
                type: TimerRecordItemEntity.self,
                entityDescriptionKey: entityKey
            )
        }
    }
}

// MARK: - Private Methods
private extension CoreDataService {
    func performFetch<TargetModel, EntityConvertedModel>(
        entityKey: CoreConstants.Label,
        operation: () async throws -> EntityConvertedModel
    ) async -> Result<TargetModel, CoreError> {
        do {
            let result = try await operation()
            guard let typedResult = result as? TargetModel else {
                return .failure(.invalidEntity)
            }
            return .success(typedResult)
        } catch {
            return .failure(.invalidEntity)
        }
    }
    
    func findItemByEntityConvertible<Entity: NSManagedObject & CoreEntityConvertible>(
        type: Entity.Type,
        _ id: String,
        entityDescriptionKey: CoreConstants.Label,
        idKey: String = "id"
    ) async throws -> Entity.T? {
        try await fetchWithPredicate(
            type: Entity.self,
            entityDescriptionKey: entityDescriptionKey,
            predicate: NSPredicate(format: "%K == %@", idKey, id as CVarArg)
        ).first
    }
    
    func findAllItemByEntityConvertible<Entity: NSManagedObject & CoreEntityConvertible>(
        type: Entity.Type,
        entityDescriptionKey: CoreConstants.Label
    ) async throws -> [Entity.T] {
        try await fetchWithPredicate(
            type: Entity.self,
            entityDescriptionKey: entityDescriptionKey,
            predicate: nil
        )
    }
    
    func findItemsByEntityConvertible<Entity: NSManagedObject & CoreEntityConvertible>(
        type: Entity.Type,
        _ ids: [String],
        entityDescriptionKey: CoreConstants.Label,
        idKey: String = "id"
    ) async throws -> [Entity.T] {
        try await fetchWithPredicate(
            type: Entity.self,
            entityDescriptionKey: entityDescriptionKey,
            predicate: NSPredicate(format: "%K IN %@", idKey, ids as [CVarArg])
        )
    }
    
    func fetchWithPredicate<Entity: NSManagedObject & CoreEntityConvertible>(
        type: Entity.Type,
        entityDescriptionKey: CoreConstants.Label,
        predicate: NSPredicate?
    ) async throws -> [Entity.T] {
        try await managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = NSFetchRequest<Entity>(entityName: entityDescriptionKey.rawValue)
            request.entity = self.getEntityDescription(key: entityDescriptionKey)
            if let predicate {
                request.predicate = predicate
            }
            let results = try self.managedObjectContext.fetch(request)
            return results.map { $0.convertToItem }
        }
    }
}
