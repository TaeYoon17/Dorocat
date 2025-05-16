//
//  CoreDataSessionStore.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//

import Foundation
import CoreData
@DBActor final class CoreDataSessionStore: SessionStoreProtocol{
    private let defaultsKeyName: String = "SessionTypes"
    private let coreDataService = CoreDataService()
    @DBActor private lazy var managedObjectContext =  {
        let context = coreDataService.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private var entityDescription: NSEntityDescription! {
        NSEntityDescription.entity(forEntityName: "SessionMenuEntity", in: self.managedObjectContext)
    }
    
    var allSessions:[SessionItem]{
        get async {
            await managedObjectContext.perform {[weak self] in
                let request:NSFetchRequest<SessionMenuEntity> = SessionMenuEntity.fetchRequest()
                let results = try! self!.managedObjectContext.fetch(request)
                return results.map{$0.convertToItem}
            }
        }
    }
    
    private var essentialItems: [SessionItem.ID]
    private var defaultSessionKey: String
    
    init(essentialItems: [SessionItem.ID], defaultSessionKey: String) async throws {
        self.essentialItems = essentialItems
        self.defaultSessionKey = defaultSessionKey
        try await updateEssentialItems(essentialItems: essentialItems, defaultSessionKey: defaultSessionKey)
    }
}


@DBActor extension CoreDataSessionStore{
    func updateEssentialItems(essentialItems:[SessionItem.ID],defaultSessionKey:String) async throws {
        let prevEssentials = self.essentialItems
        self.essentialItems = essentialItems
        self.defaultSessionKey = defaultSessionKey
        await managedObjectContext.perform {[weak self] in
            guard let self else { fatalError("스스로가 사라지는게 문제다")}
            let request = SessionMenuEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", prevEssentials)
            let results = (try? managedObjectContext.fetch(request)) ?? []
            results.forEach({self.managedObjectContext.delete($0)})
            essentialItems.forEach {
                let entity = SessionMenuEntity(entity: self.entityDescription, insertInto: self.managedObjectContext)
                entity.applyItem(SessionItem(name: $0))
            }
            do{
                try managedObjectContext.save()
            }catch{
//                print("sync error \(error)")
                fatalError("여기 문제가 있다")
            }
        }
    }
    func updateSessions(_ updatedItems: [SessionItem]) async throws {
        let essentialItems = essentialItems.map{SessionItem(name: $0)}
        let updatedCustomItems:[SessionItem] = updatedItems.filter({ !essentialItems.contains($0) })
        
        
        await managedObjectContext.perform {[weak self] in
            guard let self else { fatalError("스스로가 사라지는게 문제다")}
            let removeRequest = SessionMenuEntity.fetchRequest()
            removeRequest.predicate = NSPredicate(format: "id NOT IN %@", self.essentialItems)
            let results = (try? managedObjectContext.fetch(removeRequest)) ?? []
            results.forEach({self.managedObjectContext.delete($0)})
            updatedCustomItems.forEach {
                let entity = SessionMenuEntity(entity: self.entityDescription, insertInto: self.managedObjectContext)
                entity.applyItem($0)
            }
            do{
                try managedObjectContext.save()
            }catch{
                fatalError("여기 문제가 있다")
            }
        }
        
    }
}

extension SessionMenuEntity{
    var convertToItem: SessionItem{
        SessionItem(name: self.name!)
    }
    func applyItem(_ item: SessionItem){
        self.id = item.id
        self.name = item.name
    }
}
