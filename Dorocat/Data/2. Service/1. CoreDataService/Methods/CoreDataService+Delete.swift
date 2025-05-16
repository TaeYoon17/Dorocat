//
//  CoredataService+Delete.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation
import CoreData
extension CoreDataService {
    func deleteItemByID(
        _ id: String,
        entityKey: CoreConstants.Label,
        idKey: String = "id"
    ) async -> Result<Void,CoreError> {
        switch entityKey {
        case .timerRecordEntity:
            do {
                try await self.deleteItemByEntityConvertible(id, entityDescriptionKey: entityKey)
                return .success(())
            } catch {
                return .failure(.invalidEntity)
            }
        }
    }
    
    func deleteItemsById(
        _ ids: [String],
        entityKey: CoreConstants.Label,
        idKey: String = "id"
    ) async -> Result<Void,CoreError> {
        switch entityKey {
        case .timerRecordEntity:
            do {
                try await self.deleteItemsByEntityConvertible(ids, entityDescriptionKey: entityKey)
                return .success(())
            } catch {
                return .failure(.invalidEntity)
            }
        }
    }
    
    func deleteAllItem(
        entityKey: CoreConstants.Label,
        idKey: String = "id"
    ) async -> Result<Void,CoreError> {
        switch entityKey {
        case .timerRecordEntity:
            do {
                try await self.deleteAllItemsByEntityConvertible(entityDescriptionKey: entityKey)
                return .success(())
            } catch {
                return .failure(.invalidEntity)
            }
        }
    }
        
}
//NSPredicate(format: "%k == %@", idKey, id)
fileprivate extension CoreDataService {
    func deleteItemByEntityConvertible(
        _ id: String,
        entityDescriptionKey: CoreConstants.Label,
        idKey: String = "id"
    ) async throws {
        try await deleteWithPredicate(
            entityDescriptionKey: entityDescriptionKey,
            predicate: NSPredicate(format: "%K == %@", idKey, id)
        )
    }
    
    
    func deleteItemsByEntityConvertible(
        _ ids: [String],
        entityDescriptionKey: CoreConstants.Label,
        idKey: String = "id"
    ) async throws {
        try await deleteWithPredicate(
            entityDescriptionKey: entityDescriptionKey,
            predicate: NSPredicate(format: "%K IN %@", idKey, ids)
        )
    }
    
    func deleteAllItemsByEntityConvertible(
        entityDescriptionKey: CoreConstants.Label,
        idKey: String = "id"
    ) async throws {
        try await deleteWithPredicate(
            entityDescriptionKey: entityDescriptionKey,
            predicate: nil
        )
    }
    
    
    func deleteWithPredicate(
        entityDescriptionKey: CoreConstants.Label,
        predicate: NSPredicate?
    ) async throws {
        try await self.managedObjectContext.perform { [weak self] in
            guard let self else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityDescriptionKey.rawValue)
            request.entity = self.getEntityDescription(key: entityDescriptionKey)
            if let predicate {
                request.predicate = predicate
            }
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
    }
}

