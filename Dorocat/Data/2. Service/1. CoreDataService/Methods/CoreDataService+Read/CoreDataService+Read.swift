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
        predicateFormat: ([String]) -> String,
        args: any CVarArg...
    ) async throws -> [Model] {
        switch entityKey {
        case .timerRecordEntity:
            let predicateKeys = try attributes.map { attribute in
                guard let entityAttribute = attribute as? PartialKeyPath<TimerRecordItem> else {
                fatalError("")
                }
            return try TimerRecordItemEntity.attributes(key: entityAttribute)
            }
            
            let predicateFormatString = predicateFormat(predicateKeys)
            let predicate = NSPredicate(format: predicateFormatString, args)
            
            if let res = try await fetchWithPredicate(type: TimerRecordItemEntity.self, entityDescriptionKey: .timerRecordEntity, predicate: predicate) as? [Model] {
                return res
            } else {
                throw NSError(domain: "이게 에러임", code: 1)
            }
        }
    }
}
