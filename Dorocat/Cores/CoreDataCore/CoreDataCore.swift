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

final class CoreDataCore {
    static let shared = CoreDataCore()
    var isICloudSyncEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isIcloudSyncEnabled")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isIcloudSyncEnabled")
        }
    }
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
    var cloudKitContainer : NSPersistentCloudKitContainerOptions?
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "DoroModel")
        if let description = container.persistentStoreDescriptions.first {
            self.cloudKitContainer = description.cloudKitContainerOptions
            if !isICloudSyncEnabled {
                description.cloudKitContainerOptions = nil // CloudKit 연결 끊기
            }
        }
        
        // Load both stores.
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        // 클라우드 킷 저장소에서 이벤트가 발생하면 알려준다..!
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

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()
    
    func turnOnCloudKitSync() {
//        self.c
    }
    
    private func setupContainer() -> NSPersistentContainer {
        let iCloud = isICloudSyncEnabled
        do {
            let newContainer: NSPersistentContainer = try PersistentContainer.getContainer(iCloud: iCloud)
            guard let description: NSPersistentStoreDescription = newContainer.persistentStoreDescriptions.first else {
                fatalError("No description found")
            }
            
            if iCloud {
                newContainer.viewContext.automaticallyMergesChangesFromParent = true
                newContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            } else {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            }

            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            newContainer.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
            }
            
            return newContainer
            
        } catch {
            print(error)
        }
        
        fatalError("Could not setup Container")
    }
}
final class PersistentContainer {
    
    private static var _model: NSManagedObjectModel?
    
    private static func model(name: String) throws -> NSManagedObjectModel {
        if _model == nil {
            _model = try loadModel(name: name, bundle: Bundle.main)
        }
        return _model!
    }
    
    
    private static func loadModel(name: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw CoreDataModelError.modelURLNotFound(forResourceName: name)
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataModelError.modelLoadingFailed(forURL: modelURL)
       }
        return model
    }

    
    enum CoreDataModelError: Error {
        case modelURLNotFound(forResourceName: String)
        case modelLoadingFailed(forURL: URL)
    }

    
    public static func getContainer(iCloud: Bool) throws -> NSPersistentContainer {
        let name = "YOUR APP"
        if iCloud {
            return NSPersistentCloudKitContainer(name: name, managedObjectModel: try model(name: name))
        } else {
            return NSPersistentContainer(name: name, managedObjectModel: try model(name: name))
        }
    }
}
