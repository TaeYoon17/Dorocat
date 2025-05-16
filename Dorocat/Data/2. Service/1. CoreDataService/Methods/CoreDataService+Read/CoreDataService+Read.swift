//
//  CoreDataService+Read.swift
//  Dorocat
//
//  Created by Greem on 5/7/25.
//

import Foundation
import CoreData

extension CoreDataService {
    
    func findWithCondition <Model> (
        type: Model.Type,
        entityKey: CoreConstants.Label,
        attributes: [PartialKeyPath<Model>],
        args: any CVarArg... ,
        predicateFormat: (_ attributes: [String]) -> String
    ) async throws -> [Model] {
        switch entityKey {
        case .timerRecordEntity:
            let predicateKeys = try attributes.map { attribute in
                guard let entityAttribute = attribute as? PartialKeyPath<TimerRecordItem> else {
                    throw CoreError.invalidAttribute(attribute.customDumpDescription)
                }
            return try TimerRecordItemEntity.attributes(key: entityAttribute)
            }
            
            let predicateFormatString = predicateFormat(predicateKeys)
            let predicate = NSPredicate(format: predicateFormatString, args)
            
            if let res = try await fetchWithPredicate(
                type: TimerRecordItemEntity.self,
                entityDescriptionKey: .timerRecordEntity,
                predicate: predicate
            ) as? [Model] {
                return res
            } else {
                throw CoreError.invalidEntity
            }
        }
    }
    
    
    func count(entityKey: CoreConstants.Label, predicate: NSPredicate? = nil) throws -> Int {
        switch entityKey {
        case .timerRecordEntity:
            let fetchRequest = NSFetchRequest<TimerRecordItemEntity>(entityName: entityKey.rawValue)
            if let predicate {
                fetchRequest.predicate = predicate
            }
            return try self.managedObjectContext.count(for: fetchRequest)
        }
    }
    
    func countWithContiditon<Model>(
        type: Model.Type,
        entityKey: CoreConstants.Label,
        attributes: [PartialKeyPath<Model>],
        args: any CVarArg... ,
        predicateFormat: (_ attributes: [String]) -> String
    ) throws ->  Int {
        switch entityKey {
        case .timerRecordEntity:
            let predicateKeys = try attributes.map { attribute in
                guard let entityAttribute = attribute as? PartialKeyPath<TimerRecordItem> else {
                    throw CoreError.invalidAttribute(attribute.customDumpDescription)
                }
            return try TimerRecordItemEntity.attributes(key: entityAttribute)
            }
            let predicateFormatString = predicateFormat(predicateKeys)
            return try self.count(
                entityKey: entityKey,
                predicate: NSPredicate(format: predicateFormatString, args)
            )
        }
    }
}
