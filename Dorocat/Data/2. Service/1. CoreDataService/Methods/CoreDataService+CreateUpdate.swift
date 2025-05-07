//
//  CoredataService+Create.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation
import CoreData

extension CoreDataService {
    
    func upsertItem<Model>(
        item: Model,
        id:String,
        entityKey: CoreConstants.Label,
        idKey: String = "id"
    ) async -> Result<Void, CoreError> {
        switch entityKey {
        case .timerRecordEntity:
            guard let item = item as? TimerRecordItemEntity.T else {
                return .failure(CoreError.invalidEntity)
            }
            do {
                try await upsertByEntityConvertible(
                    type: TimerRecordItemEntity.self,
                    entityDescriptionKey: .timerRecordEntity,
                    item: item,
                    id: id
                )
                return .success(())
            } catch {
                return .failure(CoreError.invalidEntity)
            }
        }
    }
    
    fileprivate func upsertByEntityConvertible<Entity: NSManagedObject & CoreEntityConvertible>(
        type: Entity.Type,
        entityDescriptionKey: CoreConstants.Label,
        item: Entity.T,
        id: String,
        idKey: String = "id"
    ) async throws {
        self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        await self.managedObjectContext.perform { [weak self] in
            guard let self else {
                assertionFailure("추가되지 못하는 이슈")
                return
            }
            let fetchRequest = NSFetchRequest<Entity>(entityName: entityDescriptionKey.rawValue)
            fetchRequest.predicate = NSPredicate(format: "%K == %@", idKey, id)
            // 로컬에 이미 엔티티가 존재하는지 확인함
            let fetchResultEntities = try? self.managedObjectContext.fetch(fetchRequest)
            // 로컬에 존재하는 엔티티가 없으면 엔티티를 만든다.
            let recordEntity: Entity = fetchResultEntities?.first ?? type.init(
                entity: self.getEntityDescription(key: entityDescriptionKey),
                insertInto: self.managedObjectContext
            )
            recordEntity.applyItem(item)
            do {
                try self.managedObjectContext.save()
            } catch {
                assertionFailure("앱 변경사항을 제대로 저장하지 못함")
                return
            }
        }
    }
}
