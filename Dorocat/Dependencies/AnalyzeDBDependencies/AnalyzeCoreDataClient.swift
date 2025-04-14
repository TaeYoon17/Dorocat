//
//  AnalyzeCoreDataClient.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//

import Foundation
import Combine
import CoreData


//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(storeRemoteChange(_:)),
//                                               name: .NSPersistentStoreRemoteChange,
//                                               object: CoreDataCore.shared.persistentContainer.persistentStoreCoordinator)

@DBActor final class AnalyzeCoreDataClient: AnalyzeAPIs {
    private let coreDataService = CoreDataService()
    lazy var syncedDatabase: SyncedDatabase = {
        let syncedDatabase = SyncedDatabase(coreDataService: self)
        
        return syncedDatabase
    }()
    enum Label {
        static let timerRecordItemEntity = "TimerRecordItemEntity"
    }
    
    /// 가져올 엔티티
    private var entityDescription: NSEntityDescription! {
        NSEntityDescription.entity(
            forEntityName: Label.timerRecordItemEntity,
            in: coreDataService.managedObjectContext
        )
    }
    
    var totalFocusTime: Double {
        get async {
            await coreDataService.managedObjectContext.perform { [weak self] in
                guard let self else {return 0}
                let request = TimerRecordItemEntity.fetchRequest()
                request.entity = self.entityDescription
                do {
                    let results = try coreDataService.managedObjectContext.fetch(request)
                    return results.reduce(0, { $0 + Double($1.duration) })
                } catch {
                    assertionFailure("전체 시간 변환 실패 \(error)")
                    return 0
                }
            }
        }
    }
    
    func initAction() async throws {
        await syncedDatabase.setAutomaticallySync(isOn: true)
        try await syncedDatabase.fetchChanges()
    }
    
    @objc func storeRemoteChange(_ notification: Notification) {
        print("과연 가져올까??")
    }
    
    var analyzeEventContinuation: AsyncStream<AnalyzeEvent>.Continuation?
    
    func eventAsyncStream() async -> AsyncStream<AnalyzeEvent> {
        .init { [weak self] continuation in
            self?.analyzeEventContinuation = continuation
        }
    }
    
}

//MARK: -- CoreData - CRUD
extension AnalyzeCoreDataClient {
    
    private func get(date: Date, predicate: NSPredicate) async throws -> [TimerRecordItem] {
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            request.predicate = predicate
            request.sortDescriptors = [ TimerRecordItemEntity.dateSortDescriptor ]
            let results = try coreDataService.managedObjectContext.fetch(request)
            return results.map { $0.convertToItem }
        }
    }
    
    
    /// 오늘 기록 아이템들 반환
    func get(day: Date) async throws -> [TimerRecordItem] {
        let predicate = NSPredicate(format: "recordCode == %@", day.convertToRecordCode())
        return try await get(date: day, predicate: predicate)
    }
    
    /// 주간 기록 아이템들 반환
    func get(weekDate: Date) async throws -> [TimerRecordItem] {
        let predicate = NSPredicate(format: "recordCode IN %@", getCode(weekDate: weekDate))
        return try await get(date: weekDate, predicate: predicate)
    }
    
    /// 월간 기록 아이템들 반환
    func get(monthDate: Date) async throws -> [TimerRecordItem] {
        let dateCodes = getCode(monthDate: monthDate)
        let predicate = NSPredicate(format: "recordCode IN %@", dateCodes)
        return try await get(date: monthDate, predicate: predicate)
    }
    
    
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
    
    func coredataDelete(items: [TimerRecordItem]) async throws {
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
    func coredatedeleteAll() async throws {
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
    
#warning("상호의존성이 발생하는 코드")
    func coredataAppend(item: TimerRecordItem) async {
        
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
                fatalError("여기 문제가 있다")
            }
        }
    }
    
    /// 아이템 추가
    func append(_ item: TimerRecordItem) async {
        /// 여기 상호 의존성을 해제해야한다.
        await self.syncedDatabase.saveTimerRecordItem(client: self, item)
        self.analyzeEventContinuation?.yield(.append)
    }
}



fileprivate extension AnalyzeCoreDataClient {
    /// date타입을 CoreData에 저장한 코드로 변환
    func getCode(weekDate date:Date) -> [String]{
        guard let weekDay = Calendar.current.dateComponents([.weekday], from: date).weekday,
              let sundayDate = Calendar.current.date(byAdding: .day, value: -weekDay + 1, to: date) else{
            assertionFailure(#function)
            return []
        }
        let weekDates = (0...6).map{
            Calendar.current.date(byAdding: .day, value: $0, to: sundayDate)!.convertToRecordCode()
        }
        return weekDates
    }
    
    /// date타입을 CoreData에 저장한 코드로 변환
    func getCode(monthDate date: Date)->[String]{
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: calendar.dateComponents([.year,.month], from: date)),
              let endDate = calendar.date(byAdding: DateComponents(month:1,day:-1), to: startDate) else{
            assertionFailure(#function)
            return []
        }
        var currentDate = startDate
        var dateCodes: [String] = []
        while currentDate <= endDate {
            dateCodes.append(currentDate.convertToRecordCode())
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dateCodes
    }
}



extension TimerRecordItemEntity{
    static var dateSortDescriptor: NSSortDescriptor { NSSortDescriptor(key: "createdAt", ascending: false) }
    
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
