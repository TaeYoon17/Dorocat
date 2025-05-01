//
//  AnalyzeCoreDataClient.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//

import Foundation
import CoreData



@DBActor final class AnalyzeCoreDataClient {
    let coreDataService = CoreDataService()
    lazy var syncedDatabase: SyncedDatabase = SyncedDatabase()
    
    var analyzeEventContinuation: AsyncStream<AnalyzeEvent>.Continuation?
    lazy var analyzeEvent: AsyncStream<AnalyzeEvent> = .init { continuation in
        self.analyzeEventContinuation = continuation
    }
    
    enum Label {
        static let timerRecordItemEntity = "TimerRecordItemEntity"
    }
    
    /// 가져올 엔티티
    var entityDescription: NSEntityDescription! {
        NSEntityDescription.entity(
            forEntityName: Label.timerRecordItemEntity,
            in: coreDataService.managedObjectContext
        )
    }
    
    @objc func storeRemoteChange(_ notification: Notification) {
        print("과연 가져올까??")
    }
    
    
}



extension AnalyzeCoreDataClient {
    func findItemByID(_ id: TimerRecordItem.ID) async -> TimerRecordItem? {
        let timerRecordItems: [TimerRecordItem]? = try? await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
            let results = try coreDataService.managedObjectContext.fetch(request)
            return results.map { $0.convertToItem }
        }
        return timerRecordItems?.first
    }
    
    func findAllItems() async throws -> [TimerRecordItem] {
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            let results = try coreDataService.managedObjectContext.fetch(request)
            return results.map { $0.convertToItem }
        }
    }
    
    func findItemsByID(_ ids: [TimerRecordItem.ID]) async throws -> [TimerRecordItem] {
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "id IN %@", ids as [CVarArg])
            let results = try coreDataService.managedObjectContext.fetch(request)
            return results.map { $0.convertToItem }
        }
    }
    
    func timerItemDeletes(items: [TimerRecordItem]) async throws {
        guard !items.isEmpty else { return }
        let ids: [TimerRecordItem.ID] = items.map((\.id))
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return }
            let request: NSFetchRequest<TimerRecordItemEntity> = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            request.predicate = NSPredicate(format: "id IN %@", ids as [CVarArg])
            guard let resultRequest = request as? NSFetchRequest<NSFetchRequestResult> else {
                assertionFailure("변환 실패")
                return
            }
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: resultRequest)
            try coreDataService.managedObjectContext.execute(deleteRequest)
            try coreDataService.managedObjectContext.save()
        }
    }
    
    /// 모든 타이머 기록 관련 로컬 DB 데이터를 지운다.
    func timerRecordDeleteAll() async throws {
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return }
            let request: NSFetchRequest<TimerRecordItemEntity> = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            guard let resultRequest = request as? NSFetchRequest<NSFetchRequestResult> else {
                assertionFailure("변환 실패")
                return
            }
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: resultRequest)
            try coreDataService.managedObjectContext.execute(deleteRequest)
            try coreDataService.managedObjectContext.save()
        }
    }
    
    func timerItemAppend(item: TimerRecordItem) async {
        coreDataService.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else {
                assertionFailure("추가되지 못하는 이슈")
                return
            }
            let recordEntity = TimerRecordItemEntity(
                entity: entityDescription,
                insertInto: coreDataService.managedObjectContext
            )
            recordEntity.applyItem(item)
            do {
                try coreDataService.managedObjectContext.save()
            } catch {
                assertionFailure("앱 변경사항을 제대로 저장하지 못함")
                return
            }
        }
    }
}


extension TimerRecordItemEntity {
    static var dateSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: "createdAt", ascending: false)
    }
    
    func applyItem(_ item: TimerRecordItem) {
        self.id = item.id
        self.duration = Int32(item.duration)
        self.createdAt = item.createdAt
        self.recordCode = item.recordCode
        self.sessionKey = item.session.name
    }
    
    var convertToItem: TimerRecordItem {
        TimerRecordItem(
            id: self.id!,
            recordCode: self.recordCode!,
            createdAt: self.createdAt!,
            duration: Int(self.duration),
            session: .init(name: self.sessionKey!)
        )
    }
}
