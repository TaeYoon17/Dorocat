//
//  CoreDataCore.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//

import Foundation
import Combine
import CoreData
@globalActor actor DBActor: GlobalActor {
    static var shared = DBActor()
}

final class CoreDataCore{
    static let shared = CoreDataCore()
    private init(){}
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "DoroModel")
//        let storeDescription = container.persistentStoreDescriptions.first!
//        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        container.persistentStoreDescriptions = [ storeDescription ]
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    var cancellabe = Set<AnyCancellable>()
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "DoroModel")
        
        // Load both stores.
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        NotificationCenter
            .default
            .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification,
                                             object: container)
            .throttle(for: .seconds(3), scheduler: RunLoop.main, latest: true)
            .sink { complet in
                print("NSPersistentCloudKitContainer.eventChangedNotification completed")
            } receiveValue: { noti in
                print("NSPersistentCloudKitContainer.eventChangedNotification")
            }.store(in: &cancellabe)


        return container
    }()
    
}
