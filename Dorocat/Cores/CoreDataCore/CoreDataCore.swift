//
//  CoreDataCore.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//

import Foundation
import Combine
import CoreData
import CloudKit
@globalActor actor DBActor: GlobalActor {
    static var shared = DBActor()
}

@DBActor final class CoreDataService {
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DoroModel")
        let storeDescription = container.persistentStoreDescriptions.first!
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions = [ storeDescription ]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext =  {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    var isICloudSyncEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isIcloudSyncEnabled")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isIcloudSyncEnabled")
        }
    }
    init() { }
    
    
    
}
