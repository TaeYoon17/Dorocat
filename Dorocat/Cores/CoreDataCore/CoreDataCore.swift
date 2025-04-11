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

fileprivate class OnlyCoreData {
    lazy var persistentContainer: NSPersistentContainer = {
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
}

fileprivate class WithCloudKit {
    var cloudKitContainerOptions : NSPersistentCloudKitContainerOptions?
    var cancellabe: Set<AnyCancellable> = []
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "DoroModel")
//        if let description = container.persistentStoreDescriptions.first {
//            self.cloudKitContainerOptions = description.cloudKitContainerOptions
////            if !isICloudSyncEnabled {
//                description.cloudKitContainerOptions = nil // CloudKit 연결 끊기
////            }
//        }
        
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        // 클라우드 킷 저장소에서 이벤트가 발생하면 알려준다..!
        NotificationCenter.default
            .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification,
                                             object: container)
            .throttle(for: .seconds(3), scheduler: RunLoop.main, latest: true)
            .sink { complet in
                print("NSPersistentCloudKitContainer.eventChangedNotification completed")
            } receiveValue: { noti in
                print("NSPersistentCloudKitContainer.eventChangedNotification")
            }.store(in: &cancellabe)

        container.viewContext.automaticallyMergesChangesFromParent = true
        print("[CloudKit Container] persistentStoreDescriptions count: \(container.persistentStoreDescriptions.count)")
        print("[CloudKit Container] options: \(cloudKitContainerOptions?.containerIdentifier)")
        
        return container
    }()
}

final class CoreDataCore {
    static let shared = CoreDataCore()
    private let onlyCoreData = OnlyCoreData()
    private let withCloudKit = OnlyCoreData()
    var isICloudSyncEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isIcloudSyncEnabled")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isIcloudSyncEnabled")
        }
    }
    private init(){}
    lazy var persistentContainer: NSPersistentContainer = {
        return onlyCoreData.persistentContainer
//        if isICloudSyncEnabled {
//            return onlyCoreData.persistentContainer
//        } else {
//            return withCloudKit.persistentContainer
//        }
    }()
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

    
//    public static func getContainer(iCloud: Bool) throws -> NSPersistentContainer {
//        let name = "YOUR APP"
//        if iCloud {
//            return NSPersistentCloudKitContainer(name: name, managedObjectModel: try model(name: name))
//        } else {
//            return NSPersistentContainer(name: name, managedObjectModel: try model(name: name))
//        }
//    }
}
